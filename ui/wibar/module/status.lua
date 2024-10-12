local require = require

local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color   = require(beautiful.colorscheme)
local icons   = require('theme.icons')
local widget  = require('widget')
local audio   = require('signal.system.audio')
local battery = require('signal.system.battery')

local audio_widget = widget.textbox.colored({
   text  = icons['audio_muted'],
   font  = icons.font .. icons.size,
   color = color.red
})
audio:connect_signal('sinks::default', function(_, default_sink)
   if default_sink.mute or default_sink.volume == 0 then
      audio_widget.text  = icons['audio_muted']
      audio_widget.color = color.red
   elseif default_sink.volume < 50 then
      audio_widget.text  = icons['audio_decrease']
      audio_widget.color = color.fg0
   else
      audio_widget.text  = icons['audio_increase']
      audio_widget.color = color.fg0
   end
end)

-- Only assigned if a valid battery is found.
local battery_icon = widget.textbox.colored({
   text = icons.battery['UNKNOWN'],
   font = icons.font .. icons.size
})
local battery_level = widget.textbox.colored({
   text = 'N/A',
})
local battery_widget = wibox.widget({
   widget  = wibox.container.margin,
   margins = { left = dpi(12) },
   visible = false,
   {
      layout = wibox.layout.fixed.horizontal,
      spacing = dpi(6),
      battery_icon,
      battery_level
   }
})
battery:connect_signal('update', function(_, percent, state, _, _, _)
   battery_widget.visible = true

   battery_level.text = percent .. '%'
   if state == 'CHARGING' or state == 'FULLY_CHARGED' then
      battery_icon.text = icons.battery[state]
   elseif percent >= 95 then
      battery_icon.text = icons.battery['FULL']
   elseif percent >= 70 then
      battery_icon.text = icons.battery['HIGH']
   elseif percent >= 40 then
      battery_icon.text = icons.battery['NORMAL']
   elseif percent >= 20 then
      battery_icon.text = icons.battery['LOW']
   else
      battery_icon.text = icons.battery['CRITICAL']
   end
end)

return function()
   return wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      border_width = dpi(1),
      border_color = color.bg3,
      {
         widget  = wibox.container.margin,
         margins = {
            top = dpi(6), bottom = dpi(6),
            left = dpi(12), right = dpi(12)
         },
         {
            layout  = wibox.layout.fixed.horizontal,
            audio_widget,
            battery_widget
         }
      }
   })
end
