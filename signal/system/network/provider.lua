-- Uses the NM DBus interface, documentation can be found at:
--    https://people.freedesktop.org/~lkundrak/nm-docs/index.html
-- Kasper's own implementation of a similar daemon was also used as reference.
--    https://github.com/Kasper24/KwesomeDE/blob/4640500775ad70e92dc2212b7843f41445881c65/daemons/hardware/network/init.lua

local require, ipairs, table = require, ipairs, table

local gears = require('gears')

local lgi  = require('lgi')
local dbus = require('module.dbus_proxy')

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
local function get_proxy(iface, path)
   return dbus.Proxy:new({
      bus = dbus.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = iface,
      path = path
   })
end

-- Main daemon proxy.
proxy.nm = get_proxy('org.freedesktop.NetworkManager', '/org/freedesktop/NetworkManager')

-- Returns an icon name and network name for the default device (`proxy.dev.default`).
-- If the connection is wireless, the icon is representative of signal strength and the
-- name is that of the network SSID.
-- If the connection is wired, the name is the interface's.
local function get_default_information()
   local data = {}

   if proxy.dev.default == nil then
      data.name = 'No connection'
      data.icon = 'none'
      return data
   end

   local state = connectivity[proxy.nm:CheckConnectivity()]

   local conn = true
   if state == 'UNKNOWN' or state == 'NONE' then
      conn = false
   end

   -- WiFi devices get a signal strength related icon and SSID.
   if proxy.dev.default.generic.DeviceType == dev_type.WIFI then
      local ap_proxy = get_proxy('org.freedesktop.NetworkManager.AccessPoint',
                                 proxy.dev.default.typed.ActiveAccessPoint)
      data.name = nm.utils_ssid_to_utf8(ap_proxy.Ssid)
      if not conn then
         data.icon = 'wifi_none'
      else
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
local function get_devices()
   local _dev = proxy.nm:GetDevices()
   for _, path in ipairs(_dev) do
      local dev_proxy = get_proxy('org.freedesktop.NetworkManager.Device', path)

      -- Divide devices into wired or wireless.
      local typed_proxy
      if dev_proxy.DeviceType == dev_type.WIFI then
         typed_proxy = get_proxy('org.freedesktop.NetworkManager.Device.Wireless', path)
         table.insert({ generic = dev_proxy, typed = typed_proxy }, proxy.dev.wireless)
      elseif dev_proxy.DeviceType == dev_type.ETHERNET then
         typed_proxy = get_proxy('org.freedesktop.NetworkManager.Device.Wired', path)
         table.insert({ generic = dev_proxy, typed = typed_proxy }, proxy.dev.wired)
      end

      -- Add an extra entry for the current default device.
      if dev_proxy.State == dev_active then
         local active_conn = get_proxy('org.freedesktop.NetworkManager.Connection.Active',
                                       dev_proxy.ActiveConnection)
         if active_conn.Default then
            proxy.dev.default = { generic = dev_proxy, typed = typed_proxy }
         end
      end
   end
end


-- Global methods
-----------------
function obj:request_data()
   obj:emit_signal('default_change', get_default_information())
end


-- Signals
----------
-- Do an initial run of the devices.
get_devices()
obj:emit_signal('default_change', get_default_information())

-- Of course it wouldn't be that easy, can't have documentation being accurate, can we?
proxy.dev.default.generic:connect_signal(function()
   obj:emit_signal('default_change', get_default_information())
end, 'StateChanged')

-- proxy.nm:connect_signal('DeviceAdded', function()
--    print('hi')
-- end)

return obj
