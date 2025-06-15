local dbus = require('module.dbus_proxy')

local _U = {}

function _U.get_proxy(iface, path)
   return dbus.Proxy:new({
      bus = dbus.Bus.SYSTEM,
      name = 'org.freedesktop.NetworkManager',
      interface = iface,
      path = path
   })
end

return _U
