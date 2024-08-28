local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local helpers = require('helpers')
local color   = require(beautiful.colorscheme)
local icons   = require('theme.icons')
local weather = require('signal.system.weather')

return function(s)
   -- A simple widget that shows the correct suffix for the current date.
   local day_suffix = wibox.widget({ widget = wibox.widget.textbox })
   require('gears').timer({
      timeout   = 60,
      call_now  = true,
      autostart = true,
      callback  = function()
         local day = tonumber(os.date('%d'))
         day_suffix.markup = os.date('%B ') .. day .. helpers.get_suffix(day)
      end
   })

   local clock = wibox.widget({
      widget = wibox.container.background,
      fg     = color.fg0,
      {
         layout  = wibox.layout.fixed.horizontal,
         spacing = dpi(12),
         day_suffix,
         {
            widget = wibox.widget.textclock,
            format = '<b>%H:%M</b>'
         }
      },
      buttons = {
         awful.button(nil, 1, function()
            if s.time then s.time:toggle() end
         end)
      }
   })
   clock:connect_signal('mouse::enter', function(self)
      self.fg = color.accent
   end)
   clock:connect_signal('mouse::leave', function(self)
      self.fg = color.fg0
   end)

   -- Some compact weather information.
   local current_weather = wibox.widget({
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(9),
      visible = false,
      {
         widget  = wibox.container.margin,
         margins = {
            top = dpi(5), bottom = dpi(5)
         },
         {
            widget = wibox.container.background,
            bg     = color.bg2,
            forced_width = dpi(1)
         }
      },
      {
         layout = wibox.layout.fixed.horizontal,
         spacing = dpi(6),
         {
            widget = helpers.ctext({
               text = icons.weather['net_none'],
               font = icons.font .. icons.size
            }),
            id = 'icon'
         },
         {
            widget = helpers.ctext({
               text = 'N/A'
            }),
            id = 'temp'
         }
      },
      buttons = {
         awful.button(nil, 1, function()
            if s.time then s.time:toggle() end
         end)
      },
      set_col = function(self, col)
         self:get_children_by_id('icon')[1].color = col
         self:get_children_by_id('temp')[1].color = col
      end,
      set_icon = function(self, icon)
         self:get_children_by_id('icon')[1].text = icon
      end,
      set_temp = function(self, temp)
         self:get_children_by_id('temp')[1].text = temp .. '°C'
      end
   })
   current_weather:connect_signal('mouse::enter', function(self)
      self.col = color.accent
   end)
   current_weather:connect_signal('mouse::leave', function(self)
      self.col = color.fg0
   end)

   weather:connect_signal('weather::data', function(_, data)
      current_weather.visible = true
      current_weather.icon = icons.weather[data.icon]
      current_weather.temp = data.temperature
   end)

   return wibox.widget({
      layout  = wibox.layout.fixed.horizontal,
      spacing = dpi(9),
      clock,
      current_weather
   })
end
