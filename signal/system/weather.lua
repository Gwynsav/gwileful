-- The original version of this script was inspired by ChadCat's, see:
-- https://github.com/chadcat7/crystal/blob/the-awesome-config/signals/stat/weather.lua

-- This version improves upon it by adding timeouts and other measures of control, to
-- ensure that weather information is obtained or fails cleanly.

local awful = require('awful')
local gears = require('gears')

local json = require('module.json')
local user = require('config.user')

local instance = nil

-- If the user hasn't set these, don't even try.
local key    = user.weather_key
local coords = user.weather_coords
if key == nil or coords == nil then return end

local command = [[bash -c "curl -s --show-error -X GET '%s'"]]
local url =
   'https://api.openweathermap.org/data/2.5/onecall?lat=' .. coords[1] ..
   '&lon=' .. coords[2] .. '&appid=' .. key .. '&units=metric&exclude=minutely'
local shell_cmd = string.format(command, url)

-- Customizable values.
local weather = {
   poll_wait   = 720,
   timeout     = 5,
   max_retries = 11
}

local icon_map = {
   -- Daytime.
   ['01d'] = 'day_clear',
   ['02d'] = 'day_partly_cloudy',
   ['04d'] = 'day_partly_cloudy',
   ['03d'] = 'day_cloudy',
   ['09d'] = 'day_light_rain',
   ['10d'] = 'day_rain',
   ['11d'] = 'day_storm',
   ['13d'] = 'day_snow',
   ['50d'] = 'day_fog',
   -- Nighttime.
   ['01n'] = 'night_clear',
   ['02n'] = 'night_partly_cloudy',
   ['04n'] = 'night_partly_cloudy',
   ['03n'] = 'night_cloudy',
   ['09n'] = 'night_light_rain',
   ['10n'] = 'night_rain',
   ['11n'] = 'night_storm',
   ['13h'] = 'night_snow',
   ['50n'] = 'night_fog'
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
                  retries = retries + 1
                  self.timer:start()
               else
                  retries = 0
               end
            else
               self:emit_signal('get', json.decode(out))
            end
         end)
      end
   })

   -- In charge of starting an attempt to fetch weather info.
   self:connect_signal('retry', function()
      self.timer:start()
   end)

   -- Emits weather info outward.
   self:connect_signal('get', function(_, res)
      -- This usually means that the user has introduced invalid OpenWeather credentials.
      if res.current == nil then
         gears.debug.print_warning('OpenWeather credentials incorrect!')
         return
      end

      -- Right now!
      data.description = res.current.weather[1].description:gsub('^%l', string.upper)
      data.humidity    = res.current.humidity
      data.temperature = math.floor(res.current.temp)
      data.feels_like  = math.floor(res.current.feels_like)
      data.icon        = icon_map[res.current.weather[1].icon]

      -- The next 12 hours.
      data.by_hour = {}
      for i = 1, 12, 1 do
         table.insert(data.by_hour, res.hourly[i])
         data.by_hour[i].temp = math.floor(data.by_hour[i].temp)
         data.by_hour[i].icon = icon_map[res.hourly[i].weather[1].icon]
      end

      -- The next 7 days.
      data.by_day = {}
      for i = 1, 7, 1 do
         table.insert(data.by_day, res.daily[i])
         data.by_day[i].icon = icon_map[res.daily[i].weather[1].icon]
         data.by_day[i].max  = math.floor(data.by_day[i].temp.day)
         data.by_day[i].min  = math.floor(data.by_day[i].temp.night)
      end

      self:emit_signal('weather::data', data)
      retries = 0
   end)

   -- This timer runs `try` every `weather.poll_wait` seconds. It's running at all times
   -- and ensures the weather info gets updated.
   gears.timer({
      timeout = self.poll_wait,
      autostart = true,
      callback = function() self:emit_signal('retry') end
   })

   -- Same code as ran in the retry timer, meant for widgets to call directly.
   function self:request_data()
      if data.description ~= nil then
         self:emit_signal('weather::data', data)
         return
      end
      if not self.timer.started then
         awful.spawn.easy_async_with_shell(shell_cmd, function(out)
            if out == nil or out == '' then
               if retries < self.max_retries then
                  retries = retries + 1
                  self.timer:start()
               else
                  retries = 0
               end
            else
               self:emit_signal('get', json.decode(out))
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
