-- See: https://lazka.github.io/pgi-docs/UPowerGlib-1.0/classes/Device.html
local require, string, ipairs = require, string, ipairs

local gears = require('gears')

local upower = require('lgi').require('UPowerGlib')
local client = upower.Client()
local user   = require('config.user')

local instance = nil

local battery = {}

-- Default to BAT0 if the user doesn't set it, in which case the user may not actually
-- have a battery, which won't get past the for loop later on, which checks that
-- `device_path` matches a present battery before attempting to get data from it.
battery.device_path = '/org/freedesktop/UPower/devices/battery_' .. (user.battery_name or 'BAT0')
-- The only relevant ones for this use case are the first five.
battery.device_state = {
   'UNKNOWN', 'CHARGING', 'DISCHARGING', 'EMPTY', 'FULLY_CHARGED',
   'PENDING_CHARGE', 'PENDING_DISCHARGE', 'LAST'
}
-- For some reason, this enum contains some unused values, they were set to nil here.
battery.device_level = {
   'UNKNOWN', 'NONE', nil, 'LOW', 'CRITICAL', nil, 'NORMAL', 'HIGH', 'FULL', nil
}

local function new()
   local self = gears.object({})
   gears.table.crush(self, battery, true)

   local devices = client:get_devices()
   if devices ~= nil then
      -- Check the device the user wants tracked is actually present.
      local dev_found = false
      for _, dev in ipairs(devices) do
         if dev:get_object_path() == self.device_path then
            dev_found = true
            break
         end
      end
      if dev_found then
         -- Given the signal is only emitted if a valid device is found, widgets can be made
         -- to simply start off with `visible = false` and have that changed to `true` upon
         -- connecting this signal.
         require('module.awesome-battery_widget')({
            device_path = self.device_path,
            instant_update = true
         }):connect_signal('upower::update', function(_, device)
            self:emit_signal('update',
               tonumber(string.format('%.0f', device.percentage)),
               self.device_state[device.state + 1],
               self.device_level[device.battery_level + 1],
               tonumber(string.format('%.0f', device.time_to_empty / 60)),
               tonumber(string.format('%.0f', device.time_to_full / 60))
            )
         end)
      end
   end

   return self
end

if not instance then
   instance = new()
end

return instance
