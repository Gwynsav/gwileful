local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi   = beautiful.xresources.apply_dpi
local color = require(beautiful.colorscheme)
local icons = require('theme.icons')

local helpers = require('helpers')
local audio   = require('signal.system.audio')

local audio_widget = helpers.ctext({
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
local battery_widget
awesome.connect_signal('upower::update', function(percent, state, level, _, _)
   -- This is a bit ugly, but for some reason using `visible = false` instead adds some
   -- random space at the end of the layout regardless of widget position.
   if battery_widget == nil then
      battery_widget = wibox.widget({
         layout = wibox.layout.fixed.horizontal,
         spacing = dpi(8),
         {
            widget = helpers.ctext({
               text = icons.battery['UNKNOWN'],
               font = icons.font .. icons.size
            }),
            id = 'icon_role'
         },
         {
            widget = helpers.ctext({ text = 'N/A' }),
            id = 'text_role'
         },
         set_text = function(self, new_text)
            self:get_children_by_id('text_role')[1].text = new_text
         end,
         set_icon = function(self, new_icon)
            self:get_children_by_id('text_role')[1].text = new_icon
         end,
         set_color = function(self, new_color)
            self:get_children_by_id('text_role')[1].color = new_color
            self:get_children_by_id('icon_role')[1].color = new_color
         end
      })
   end

   battery_widget.text = percent .. '%'
   if helpers.in_table(state, { 'CHARGING', 'FULLY_CHARGED' }) then
      battery_widget.icon = icons.battery[state]
   else
      battery_widget.icon = icons.battery[level]
   end
end)

return function()
   return wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      {
         widget  = wibox.container.margin,
         margins = {
            -- `awful.widget.keyboardlayout` has pretty funky spacing.
            top = dpi(6), bottom = dpi(6),
            left = dpi(12), right = dpi(7)
         },
         {
            layout  = wibox.layout.fixed.horizontal,
            spacing = dpi(9),
            battery_widget,
            audio_widget,
            awful.widget.keyboardlayout
         }
      }
   })
end
