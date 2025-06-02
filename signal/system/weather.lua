-- The original version of this script was inspired by ChadCat's, see:
-- https://github.com/chadcat7/crystal/blob/the-awesome-config/signals/stat/weather.lua

-- This version improves upon it by adding timeouts and other measures of control, to
-- ensure that weather information is obtained or fails cleanly.
local require, string, math, table = require, string, math, table

local awful = require('awful')
local gears = require('gears')

local json = require('module.json')
local user = require('config.user')

local instance = nil

-- Allow custom locations and units. If not set, use defaults!
local args = { area = user.area, imperial = user.imperial }
local conf = gears.table.crush({
   area     = '',
   imperial = false
}, args, true)

if conf.area == nil then
   gears.debug.print_warning('No location provided, using wttr.in default (IP-based)!')
end

-- The information source.
local command = [[bash -c "curl -s --show-error -X GET '%s'"]]
local url =
   'wttr.in/' .. conf.area .. '?format=j1'
local shell_cmd = string.format(command, url)

-- Customizable values.
local weather = {
   poll_wait   = 720,
   timeout     = 15,
   max_retries = 7
}

-- O our Father who art in heaven... 
local icon_map = {
   -- Daytime.
   ['113d'] = 'day_clear',
   ['116d'] = 'day_partly_cloudy',
   ['119d'] = 'day_cloudy',
   ['122d'] = 'day_cloudy',
   ['143d'] = 'day_fog',
   ['176d'] = 'day_light_rain',
   ['179d'] = 'day_light_rain',
   ['182d'] = 'day_light_rain',
   ['185d'] = 'day_light_rain',
   ['200d'] = 'day_storm',
   ['227d'] = 'day_snow',
   ['230d'] = 'day_snow',
   ['248d'] = 'day_fog',
   ['260d'] = 'day_fog',
   ['263d'] = 'day_light_rain',
   ['266d'] = 'day_light_rain',
   ['281d'] = 'day_light_rain',
   ['284d'] = 'day_light_rain',
   ['293d'] = 'day_light_rain',
   ['296d'] = 'day_light_rain',
   ['299d'] = 'day_rain',
   ['302d'] = 'day_rain',
   ['305d'] = 'day_rain',
   ['308d'] = 'day_rain',
   ['311d'] = 'day_light_rain',
   ['314d'] = 'day_light_rain',
   ['317d'] = 'day_light_rain',
   ['320d'] = 'day_snow',
   ['323d'] = 'day_snow',
   ['326d'] = 'day_snow',
   ['329d'] = 'day_snow',
   ['332d'] = 'day_snow',
   ['335d'] = 'day_snow',
   ['338d'] = 'day_snow',
   ['350d'] = 'day_light_rain',
   ['353d'] = 'day_light_rain',
   ['356d'] = 'day_rain',
   ['359d'] = 'day_rain',
   ['362d'] = 'day_light_rain',
   ['365d'] = 'day_light_rain',
   ['368d'] = 'day_snow',
   ['371d'] = 'day_snow',
   ['374d'] = 'day_light_rain',
   ['377d'] = 'day_light_rain',
   ['386d'] = 'day_storm',
   ['389d'] = 'day_storm',
   ['392d'] = 'day_snow',
   ['395d'] = 'day_snow',
   -- Nighttime.
   ['113n'] = 'night_clear',
   ['116n'] = 'night_partly_cloudy',
   ['119n'] = 'night_cloudy',
   ['122n'] = 'night_cloudy',
   ['143n'] = 'night_fog',
   ['176n'] = 'night_light_rain',
   ['179n'] = 'night_light_rain',
   ['182n'] = 'night_light_rain',
   ['185n'] = 'night_light_rain',
   ['200n'] = 'night_storm',
   ['227n'] = 'night_snow',
   ['230n'] = 'night_snow',
   ['248n'] = 'night_fog',
   ['260n'] = 'night_fog',
   ['263n'] = 'night_light_rain',
   ['266n'] = 'night_light_rain',
   ['281n'] = 'night_light_rain',
   ['284n'] = 'night_light_rain',
   ['293n'] = 'night_light_rain',
   ['296n'] = 'night_light_rain',
   ['299n'] = 'night_rain',
   ['302n'] = 'night_rain',
   ['305n'] = 'night_rain',
   ['308n'] = 'night_rain',
   ['311n'] = 'night_light_rain',
   ['314n'] = 'night_light_rain',
   ['317n'] = 'night_light_rain',
   ['320n'] = 'night_snow',
   ['323n'] = 'night_snow',
   ['326n'] = 'night_snow',
   ['329n'] = 'night_snow',
   ['332n'] = 'night_snow',
   ['335n'] = 'night_snow',
   ['338n'] = 'night_snow',
   ['350n'] = 'night_light_rain',
   ['353n'] = 'night_light_rain',
   ['356n'] = 'night_rain',
   ['359n'] = 'night_rain',
   ['362n'] = 'night_light_rain',
   ['365n'] = 'night_light_rain',
   ['368n'] = 'night_snow',
   ['371n'] = 'night_snow',
   ['374n'] = 'night_light_rain',
   ['377n'] = 'night_light_rain',
   ['386n'] = 'night_storm',
   ['389n'] = 'night_storm',
   ['392n'] = 'night_snow',
   ['395n'] = 'night_snow',
}
-- Amen.

local function suffix(time)
   time = tonumber(time)
   return (time > 19 or time < 6) and 'n' or 'd'
end

local function hhmm_to_hh(time)
   return string.format('%02d', math.floor(tonumber(time) / 100))
end

-- snow > storm > rain > fog > light_rain > cloudy > partly_cloudy > clear
local weight_map = {
   ['day_snow'] = 7,
   ['night_snow'] = 7,
   ['day_storm'] = 6,
   ['night_storm'] = 6,
   ['day_rain'] = 5,
   ['night_rain'] = 5,
   ['day_fog'] = 4,
   ['night_fog'] = 4,
   ['day_light_rain'] = 3,
   ['night_light_rain'] = 3,
   ['day_cloudy'] = 2,
   ['night_cloudy'] = 2,
   ['day_partly_cloudy'] = 1,
   ['night_partly_cloudy'] = 1,
   ['day_clear'] = 0,
   ['night_clear'] = 0
}

local function new()
   local self = gears.object({})
   gears.table.crush(self, weather, true)
   local retries = 0
   local data = {}

   -- This timer is a fetch attempt timeout. If it fails to get the weather info, it will
   -- wait for `weather.timeout` seconds and try again, up to `weather.max_retries`
   -- retries. After that it will give up and wait for the next emision of the `retry`
   -- signal. If information is obtained successfully, it's emitted through an object
   -- signal.
   self.timer = gears.timer({
      timeout = self.timeout,
      call_now = true,
      single_shot = true,
      callback = function()
         awful.spawn.easy_async_with_shell(shell_cmd, function(out)
            if out == nil or out == '' then
               if retries < self.max_retries then
                  print("Weather fetching failed, retrying...")
                  retries = retries + 1
                  self.timer:start()
               else
                  retries = 0
               end
            else
               self:get(json.decode(out))
            end
         end)
      end
   })

   -- Emits weather info outward.
   function self:get(res)
      if res.current_condition[1] == nil then
         gears.debug.print_warning('Failed to fetch weather info!')
         return
      end

      -- Right now!
      local current = res.current_condition[1]
      local today = res.weather[1]
      data.description = current.weatherDesc[1].value
      data.humidity    = current.humidity .. '%'
      data.temperature = conf.imperial and current.temp_F .. '°F'
                                       or current.temp_C .. '°C'
      data.feels_like  = conf.imperial and current.FeelsLikeF .. '°F'
                                       or current.FeelsLikeC .. '°C'
      data.icon     = icon_map[current.weatherCode .. suffix(os.date('%H'))]
      data.max_temp = conf.imperial and today.maxtempF .. '°F'
                                    or today.maxtempC .. '°C'
      data.min_temp = conf.imperial and today.mintempF .. '°F'
                                    or today.mintempC .. '°C'

      -- The next 8 hours.
      data.by_hour = {}
      for i = 1, 8, 1 do
         local fc = today.hourly[i]
         local hour = {
            time        = hhmm_to_hh(fc.time) .. ':00',
            description = fc.weatherDesc[1].value,
            humidity    = fc.humidity .. '%',
            temperature = conf.imperial and fc.tempF .. '°F'
                                        or fc.tempC .. '°C',
            rain_chance = fc.chanceofrain .. '%',
            icon = icon_map[fc.weatherCode .. suffix(hhmm_to_hh(fc.time))]
         }
         table.insert(data.by_hour, hour)
      end

      -- The next 2 days.
      data.by_day = {}
      for i = 2, 3, 1 do
         local fc = res.weather[i]
         local day = {}
         day.max_temp = conf.imperial and fc.maxtempF .. '°F'
                                      or fc.maxtempC .. '°C'
         day.min_temp = conf.imperial and fc.mintempF .. '°F'
                                      or fc.mintempC .. '°C'

         -- NOTE: none of these are actually given. Must be calculated from hourly
         -- forecast.
         local worst = -1
         local icon  = icon_map['113d']
         local rain  = 0
         local hum   = 0
         for j = 1, #fc.hourly, 1 do
            -- Get icon. wttr.in does not provide an icon for a day's general weather, so
            -- we get that from the "worst" weather in the day.
            local hour = fc.hourly[j]
            local status = icon_map[hour.weatherCode .. suffix(hhmm_to_hh(hour.time))]
            if weight_map[status] > worst then
               worst = weight_map[status]
               icon  = status
            end
            -- Get chance of rain as the worst chance of rain in the day.
            local chance = tonumber(hour.chanceofrain)
            if chance > rain then
               rain = chance
            end
            -- Get humidity as the mean humidity of the day.
            hum = hum + tonumber(hour.humidity)
         end
         day.icon = icon
         day.rain_chance = rain .. '%'
         day.humidity = math.floor(hum / #fc.hourly) .. '%'

         table.insert(data.by_day, day)
      end

      self:emit_signal('weather::data', data)
      retries = 0
   end

   -- This timer runs `try` every `weather.poll_wait` seconds. It's running at all times
   -- and ensures the weather info gets updated.
   gears.timer({
      timeout = self.poll_wait,
      autostart = true,
      callback = function() self.timer:start() end
   })

   -- Same code as ran in the retry timer, meant for widgets to call directly.
   function self:request_data()
      if data.description ~= nil then
         self:emit_signal('weather::data', data)
         return
      end
      if not self.timer.started then
         awful.spawn.easy_async_with_shell(shell_cmd, function(out)
            -- Test and test and try...
            if not self.timer.started then
               if out == nil or out == '' then
                  if retries < self.max_retries then
                     retries = retries + 1
                     self.timer:start()
                  else
                     retries = 0
                  end
               else
                  self:get(json.decode(out))
               end
            end
         end)
      end
   end

   return self
end

if not instance then
   instance = new()
end
return instance
