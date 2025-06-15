-- Uses the NM DBus interface, documentation can be found at:
--    https://people.freedesktop.org/~lkundrak/nm-docs/index.html
-- Kasper's own implementation of a similar daemon was also used as reference.
--    https://github.com/Kasper24/KwesomeDE/blob/4640500775ad70e92dc2212b7843f41445881c65/daemons/hardware/network/init.lua

local require, ipairs, table = require, ipairs, table

local gears = require('gears')

local lgi  = require('lgi')
local dbus = require('module.dbus_proxy')
local helpers = require('helpers')

local obj = gears.object({})

-- If NetworkManager isn't accessible, don't even try.
local nm_status, nm = pcall(function()
   return lgi.NM
end)
if not nm_status or not nm then
   gears.debug.print_warning('Unable to access NM DBus interface!')
   return
end


-- Constants
------------
local connectivity = { 'UNKNOWN', 'NONE', 'PORTAL', 'LIMITED', 'FULL' }
local dev_type = { ETHERNET = 1, WIFI = 2 }
local dev_active = 100


-- Proxies
----------
local proxy = {}

-- Proxies for devices managed by NM.
proxy.dev = {
   wireless = {},
   wired = {}
}


-- Auxiliary functions
----------------------
local _p = {}

function _p.get_proxy(iface, path)
   return dbus.Proxy:new({
      bus = dbus.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = iface,
      path = path
   })
end

-- Main daemon proxy.
proxy.nm =
   _p.get_proxy('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager')

-- Returns an icon name and network name for the default device (`proxy.dev.default`).
-- If the connection is wireless, the icon is representative of signal strength and the
-- name is that of the network SSID.
-- If the connection is wired, the name is the interface's.
function _p.get_default_information()
   local data = {}

   -- No connection.
   if proxy.dev.default == nil then
      data.name = 'No connection'
      data.icon = 'none'
      return data
   end

   -- Connected but unable to access the internet.
   local conn = true
   local state = connectivity[proxy.nm:CheckConnectivity()]
   if state == 'UNKNOWN' or state == 'NONE' then
      conn = false
   end

   -- WiFi devices get a signal strength related icon and SSID.
   if proxy.dev.default.generic.DeviceType == dev_type.WIFI then
      local ap_proxy = _p.get_proxy('org.freedesktop.NetworkManager.AccessPoint',
                                    proxy.dev.default.typed.ActiveAccessPoint)
      if not conn or ap_proxy.Ssid == nil then
         data.name = 'No connection'
         data.icon = 'wifi_none'
      else
         data.name = nm.utils_ssid_to_utf8(ap_proxy.Ssid)
         if ap_proxy.Strength > 66 then
            data.icon = 'wifi_high'
         elseif ap_proxy.Strength > 33 then
            data.icon = 'wifi_normal'
         else
            data.icon = 'wifi_low'
         end
      end
   -- Ethernet interfaces get a yes or no icon and their name.
   elseif proxy.dev.default.generic.DeviceType == dev_type.ETHERNET then
      data.name = proxy.dev.default.generic.Interface
      if not conn then
         data.icon = 'wired_none'
      else
         data.icon = 'wired_normal'
      end
   end

   return data
end

-- Gets all active devices and classifies them into wired or wireless. Ignores symbolic
-- interfaces such as loopback. Also binds the default device to `proxy.dev.default`.
function _p.get_devices()
   proxy.dev.wireless = helpers.clear_array(proxy.dev.wireless)
   proxy.dev.wired    = helpers.clear_array(proxy.dev.wired)

   -- Filters out "placeholder" devices such as loopback.
   local _dev = proxy.nm:GetDevices()
   for _, path in ipairs(_dev) do
      local dev_proxy = _p.get_proxy('org.freedesktop.NetworkManager.Device', path)

      -- Divide devices into wired or wireless.
      local typed_proxy
      if dev_proxy.DeviceType == dev_type.WIFI then
         typed_proxy =
            _p.get_proxy('org.freedesktop.NetworkManager.Device.Wireless', path)
         table.insert(proxy.dev.wireless, { generic = dev_proxy, typed = typed_proxy })
      elseif dev_proxy.DeviceType == dev_type.ETHERNET then
         typed_proxy =
            _p.get_proxy('org.freedesktop.NetworkManager.Device.Wired', path)
         table.insert(proxy.dev.wired, { generic = dev_proxy, typed = typed_proxy })
      end
   end

   _p.get_default()
end

function _p.get_default()
   -- Returns true if the device owns the default route to reach the internet.
   -- False otherwise.
   local function is_default(dev)
      if dev.generic.State == dev_active then
         local active_conn =
            _p.get_proxy('org.freedesktop.NetworkManager.Connection.Active',
                         dev.generic.ActiveConnection)
         if active_conn.Default then return true end
      end
      return false
   end

   local default = nil

   -- Check through wired devices.
   for _, dev in ipairs(proxy.dev.wired) do
      if is_default(dev) then
         default = dev
         break
      end
   end

   -- Check through wireless devices.
   if default == nil then
      for _, dev in ipairs(proxy.dev.wireless) do
         if is_default(dev) then
            default = dev
            break
         end
      end
   end

   proxy.dev.default = default
end

function _p.handle_device_change()
   _p.get_devices()
   obj:emit_signal('default_change', _p.get_default_information())
end


-- Global methods
-----------------
function obj:request_data()
   obj:emit_signal('default_change', _p.get_default_information())
end


-- Init
-------
_p.get_devices()
obj:emit_signal('default_change', _p.get_default_information())


-- Signals
----------
proxy.nm:connect_signal(function()
   _p.get_default()
   obj:emit_signal('default_change', _p.get_default_information())
end, 'StateChanged')

-- On a new device being added or a current one being removed.
proxy.nm:connect_signal(_p.handle_device_change(), 'DeviceAdded')
proxy.nm:connect_signal(_p.handle_device_change(), 'DeviceRemoved')

return obj
