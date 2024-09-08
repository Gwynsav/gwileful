local require, string, table, ipairs, print = require, string, table, ipairs, print

local gears = require('gears')

local lgi  = require('lgi')
local dbus = require('module.dbus_proxy')

local instance = nil
local net = {}

local _NM_status, NM = pcall(function()
   return lgi.NM
end)

if not _NM_status or not NM then
   gears.debug.print_warning('Failed to connect to NM interface.')
   return
end

local DEV_TYPE = { WIRED = 1, WIRELESS = 2 }

local function flags_to_string(flags, wpa_flags, rsn_flags)
   local str = ''

   if flags == 1 and wpa_flags == 0 and rsn_flags == 0 then
      str = str .. ' WEP'
   end
   if wpa_flags ~= 0 then
      str = str .. ' WPA1'
   end
   if rsn_flags == 0 then
      str = str .. ' WPA2'
   end
   if wpa_flags == 512 or rsn_flags == 512 then
      str = str .. ' 802.1X'
   end

   return str
end

local function get_ap_conns(self, ssid)
   local conns = {}

   for _, conn_path in ipairs(self._private.settings:ListConnections()) do
      local conn = dbus.Proxy:new({
         bus = dbus.Bus.SYSTEM,
         name = 'org.freedesktop.NetworkManager',
         interface = 'org.freedesktop.NetworkManager.Settings.Connection',
         path = conn_path
      })

      if string.find(conn.Filename, ssid) then
         table.insert(conns, conn)
      end
   end

   return conns
end

local function get_dev_proxy(self)
   local devs = self._private.client:GetDevices()
   for _, dev_path in ipairs(devs) do
      local dev = dbus.Proxy:new({
         bus = dbus.Bus.SYSTEM,
         name = 'org.freedesktop.NetworkManager',
         interface = 'org.freedesktop.NetworkManager.Device',
         path = dev_path
      })

      if dev.DeviceType == DEV_TYPE.WIRELESS then
         self._private.dev = dev
         self._private.wifi = dbus.Proxy:new({
            bus = dbus.Bus.SYSTEM,
            name = 'org.freedesktop.NetworkManager',
            interface = 'org.freedesktop.NetworkManager.Device.Wireless',
            path = dev_path
         })
         self._private.dev:connect_signal('StateChanged', function(proxy, new, old, reason)
            -- idk
         end)
      elseif dev.DeviceType == DEV_TYPE.WIRED then
         self._private.dev = dev
         self._private.wired = dbus.Proxy:new({
            bus = dbus.Bus.SYSTEM,
            name = 'org.freedesktop.NetworkManager',
            interface = 'org.freedesktop.NetworkManager.Device.Ethernet',
            path = dev_path
         })
         self._private.dev:connect_signal('StateChanged', function(proxy, new, old, reason)
            -- idk
         end)
      end
   end
end

-- O(n*log(n))
-- **Considering the amount of connections existing to an access point negligible in
-- comparison to the amount of present access points.
-- ***Lua `table.sort` is a C programmed quicksort implementation.
function net:scan_aps()
   if self._private.wifi == nil then return end

   -- Reset access point list.
   self._private.aps = {}
   self._private.wifi:RequestScanAsync(function(_, _, _, failure)
      if failure ~= nil then
         gears.debug.print_warning('Failed to scan for access points.')
         self:emit_signal('wireless::scan::failed', tostring(failure.code))
         return
      end

      -- Scan all access points.
      local aps = self._private.wifi:GetAccessPoints()
      for _, ap_path in ipairs(aps) do
         -- Create a dbus proxy for the access point.
         local ap = dbus.Proxy:new({
            bus = dbus.Bus.SYSTEM,
            name = 'org.freedesktop.NetworkManager',
            interface = 'org.freedesktop.NetworkManager.AccessPoint',
            path = ap_path
         })

         if ap.Ssid ~= nil then
            -- Obtain its info.
            local ssid     = NM.utils_ssid_to_utf8(ap.Ssid)
            local security = flags_to_string(ap.Flags, ap.WpaFlags, ap.RsnFlags)
            local password = ''
            local conns    = get_ap_conns(self, ssid)

            -- If it has a saved connection, get its password.
            for _, conn in ipairs(conns) do
               if string.find(conn.Filename, ssid) then
                  local secrets = conn:GetSecrets('802-11-wireless-security')
                  if secrets ~= nil then
                     password = secrets['802-11-wireless-security'].psk
                     break
                  end
               end
            end

            -- Add the access point info to the access point table.
            local ret = {
               raw_ssid = ap.Ssid,
               ssid     = ssid,
               security = security,
               password = password,
               strength = ap.Strength,
               path     = ap_path,
               dev_if   = self._private.dev.Interface,
               dev_path = self._private.dev.object_path,
               hw_address = ap.HwAddress
            }
            gears.table.crush(ret, ap, true)

            print('Adding AP: ' .. ssid)
            table.insert(self._private.aps, ret)
         end
      end

      -- Sort the access point based on their signal strength.
      table.sort(self._private.aps, function(a, b)
         return a.strength > b.strength
      end)

      -- Return table of access points.
      print('Access point scan successful.')
      self:emit_signal('wireless::scan::success', self._private.aps)
   end)
end

function net:set_networking(state)
   self._private.client:Enable(state)
end

function net:get_aps()
   return self._private.aps
end


local function new()
   local self = gears.object({})
   gears.table.crush(self, net, true)

   self._private = {}
   self._private.aps = {}

   self._private.client = dbus.Proxy:new({
      bus = dbus.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = 'org.freedesktop.NetworkManager',
      path = '/org/freedesktop/NetworkManager'
   })

   self._private.settings = dbus.Proxy:new({
      bus = dbus.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = 'org.freedesktop.NetworkManager.Settings',
      path = '/org/freedesktop/NetworkManager/Settings'
   })

   local client_props = dbus.Proxy:new({
      bus = dbus.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = 'org.freedesktop.Dbus.Properties',
      path = '/org/freedesktop/NetworkManager'
   })

   local ap_scan_timer = gears.timer({
      timeout = 5,
      callback = function()
         print('Attempting AP scan.')
         self:scan_aps()
         return false
      end
   })

   client_props:connect_signal('PropertiesChanged', function(_, _, data)
      if not data.NetworkingEnabled then return end

      if (data.WirelessEnabled ~= nil and
            data.WirelessEnabled ~= self._private.wireless_enabled) then
         self._private.wireless_enabled = data.WirelessEnabled
         self:emit_signal('wireless::state', data.WirelessEnabled)

         if data.WirelessEnabled then
            ap_scan_timer:start()
         else
            ap_scan_timer:stop()
         end
      end
   end)

   get_dev_proxy()

   return self
end

if not instance then
   instance = new()
end

return instance
