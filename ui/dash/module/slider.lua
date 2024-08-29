local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local pctl    = require('module.bling').signal.playerctl.lib()
local helpers = require('helpers')
local audio   = require('signal.system.audio')
local color   = require(beautiful.colorscheme)
local icons   = require('theme.icons')

-- Creates a slider, with an icon, label and percentage values attached.
-- @param args:
--    - label, the text shown next to the icon.
--    - icon, the icon used in normal state.
--    - icon_click, the action to perform when clicking the icon.
--    - bar_action, what to do with new values of the slider.
local function slider(args)
   -- Icon.
   local icon = helpers.ctext({
      text = args.icon,
      font = icons.font .. icons.size
   })
   icon.buttons = { awful.button(nil, 1, args.icon_click) }
   icon:connect_signal('mouse::enter', function(self)
      self.color = color.accent
   end)
   icon:connect_signal('mouse::leave', function(self)
      self.color = color.fg0
   end)

   local label = helpers.ctext({ text = args.label })

   -- Slider.
   local bar = wibox.widget({
      widget = wibox.widget.slider,
      bar_height = dpi(21),
      bar_color  = color.bg1,
      handle_width = dpi(4),
      handle_border_width = 0,
      bar_border_width = dpi(2),
      bar_border_color = color.bg3,
      bar_active_color = color.bg2,
      handle_color = color.bg3,
      minimum = 0,
      maximum = 100,
      value = 0,
      id = 'slider_role'
   })
   local is_hovered = false
   bar:connect_signal('mouse::enter', function(self)
      is_hovered = true
      self.handle_color     = color.accent
      self.bar_border_color = color.accent
   end)
   bar:connect_signal('mouse::leave', function(self)
      is_hovered = false
      self.handle_color     = color.bg3
      self.bar_border_color = color.bg3
   end)
   bar:connect_signal('property::value', function(_, val)
      if is_hovered then
         args.bar_action(_, val)
      end
   end)

   -- Non-interactable level.
   local level = helpers.ctext({ text = 'N/A' })

   return wibox.widget({
      widget   = wibox.container.constraint,
      strategy = 'exact',
      height   = dpi(21),
      {
         layout = wibox.layout.stack,
         bar,
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(5), bottom = dpi(3),
               left = dpi(7), right = dpi(7)
            },
            {
               layout = wibox.layout.align.horizontal,
               {
                  layout  = wibox.layout.fixed.horizontal,
                  spacing = dpi(7),
                  icon,
                  {
                     widget   = wibox.container.constraint,
                     strategy = 'max',
                     width    = dpi(200),
                     label
                  }
               },
               nil,
               level
            }
         }
      },
      set_value = function(_, value)
         bar.value = value
      end,
      set_level = function(_, value)
         level.text = value .. '%'
      end,
      set_label = function(_, value)
         label.text = value
      end,
      set_icon = function(_, value)
         icon.text = value
      end
   })
end

local volume_slider = slider({
   label       = 'Audio Device Unknown',
   icon        = icons['audio_muted'],
   icon_click  = function() audio:default_sink_toggle_mute() end,
   bar_action  = function(_, new) audio:default_sink_set_volume(new) end
})
audio:connect_signal('sinks::default', function(_, default_sink)
   volume_slider.value = default_sink.volume
   volume_slider.level = default_sink.volume
   if default_sink.mute or default_sink.volume == 0 then
      volume_slider.icon = icons['audio_muted']
   elseif default_sink.volume >= 50 then
      volume_slider.icon = icons['audio_increase']
   else
      volume_slider.icon = icons['audio_decrease']
   end
   volume_slider.label = default_sink.description
end)

local mic_slider = slider({
   label       = 'Microphone Unknown',
   icon        = icons['mic_muted'],
   icon_click  = function() audio:default_source_toggle_mute() end,
   bar_action  = function(_, new) audio:default_source_set_volume(new) end
})
audio:connect_signal('sources::default', function(_, default_source)
   mic_slider.value = default_source.volume
   mic_slider.level = default_source.volume
   if default_source.mute or default_source.volume == 0 then
      mic_slider.icon = icons['mic_muted']
   elseif default_source.volume >= 50 then
      mic_slider.icon = icons['mic_increase']
   else
      mic_slider.icon = icons['mic_decrease']
   end
   mic_slider.label = default_source.description
end)

local music_slider = slider({
   label       = 'Player Unknown',
   icon        = icons['music'],
   icon_click  = function() end,
   bar_action  = function(_, new) pctl:set_volume(new / 100) end
})
pctl:connect_signal('volume', function(_, volume, player)
   music_slider.label = player
   local value = math.floor((volume or 0) * 100)
   music_slider.value = value
   music_slider.level = value
end)

return function()
   return wibox.widget({
      layout = wibox.layout.fixed.vertical,
      spacing = dpi(9),
      music_slider,
      volume_slider,
      mic_slider
   })
end
