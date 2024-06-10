local beautiful = require('beautiful')
local wibox = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local audio = require('signal.system.audio')
local color = require(beautiful.colorscheme)

local function slider()
   local bar = wibox.widget({
      widget = wibox.widget.slider,
      bar_height = dpi(1),
      bar_color  = color.fg2,
      handle_width = dpi(9),
      handle_color = color.fg0,
      value = 0
   })
   bar:connect_signal('mouse::enter', function(self)
      self.bar_color = color.accent
   end)
   bar:connect_signal('mouse::leave', function(self)
      self.bar_color = color.fg2
   end)

   return bar
end

local volume_slider = slider()
awesome.connect_signal('sink::get', function(_, volume)
   volume_slider.value = volume
end)
volume_slider:connect_signal('property::value', function(_, new)
   audio:set_sink_volume(new)
end)

return function()
   return wibox.widget({
      widget = wibox.container.constraint,
      strategy = 'exact',
      height = dpi(9),
      volume_slider
   })
end
