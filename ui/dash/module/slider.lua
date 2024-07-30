local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local pctl    = require('module.bling').signal.playerctl.lib()
local helpers = require('helpers')
local audio   = require('signal.system.audio')
local color   = require(beautiful.colorscheme)

-- Creates a slider, with an icon, label and percentage values attached.
-- @param args:
--    - label, the text shown next to the icon.
--    - icon_normal, the icon used in normal state.
--    - icon_hover, the icon used when hovered.
--    - icon_click, the action to perform when clicking the icon.
--    - bar_action, what to do with new values of the slider.
local function slider(args)
   -- Icon.
   local icon = wibox.widget({
      widget = wibox.widget.imagebox,
      image  = args.icon_normal,
      forced_height = dpi(9),
      forced_width  = dpi(9),
      scaling_quality = 'nearest',
      buttons = {
         awful.button(nil, 1, args.icon_click)
      }
   })
   icon:connect_signal('mouse::enter', function(self)
      self.image = args.icon_hover
   end)
   icon:connect_signal('mouse::leave', function(self)
      self.image = args.icon_normal
   end)

   local label = helpers.ctext({ text = args.label })

   -- Slider.
   local bar = wibox.widget({
      widget = wibox.widget.slider,
      bar_height = dpi(19),
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
   bar:connect_signal('mouse::enter', function(self)
      self.handle_color     = color.accent
      self.bar_border_color = color.accent
   end)
   bar:connect_signal('mouse::leave', function(self)
      self.handle_color     = color.bg3
      self.bar_border_color = color.bg3
   end)
   bar:connect_signal('property::value', args.bar_action)

   -- Non-interactable level.
   local level = helpers.ctext({ text = 'N/A' })

   return wibox.widget({
      widget   = wibox.container.constraint,
      strategy = 'exact',
      height   = dpi(19),
      {
         layout = wibox.layout.stack,
         bar,
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(5), bottom = dpi(5),
               left = dpi(7), right = dpi(7)
            },
            {
               layout = wibox.layout.align.horizontal,
               {
                  layout  = wibox.layout.fixed.horizontal,
                  spacing = dpi(7),
                  icon,
                  -- Font alignment :P
                  {
                     widget = wibox.container.margin,
                     margins = { bottom = dpi(-1) },
                     {
                        widget   = wibox.container.constraint,
                        strategy = 'max',
                        width    = dpi(200),
                        label
                     }
                  }
               },
               nil,
               {
                  widget = wibox.container.margin,
                  margins = { bottom = dpi(-1) },
                  level
               }
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
      end
   })
end

local volume_slider = slider({
   label       = 'Audio Device Unknown',
   icon_normal = beautiful.vol_up,
   icon_hover  = beautiful.vol_up_hl,
   icon_click  = function() audio:toggle_sink_mute() end,
   bar_action  = function(_, new) audio:set_sink_volume(new) end
})
audio:connect_signal('sink::get', function(_, _, volume)
   local value = tonumber(volume or 0)
   volume_slider.value = value
   volume_slider.level = value
end)
audio:connect_signal('sink::name', function(_, name)
   volume_slider.label = name
end)

local mic_slider = slider({
   label       = 'Microphone Unknown',
   icon_normal = beautiful.mic_up,
   icon_hover  = beautiful.mic_up_hl,
   icon_click  = function() audio:toggle_source_mute() end,
   bar_action  = function(_, new) audio:set_source_volume(new) end
})
audio:connect_signal('source::get', function(_, _, volume)
   local value = tonumber(volume or 0)
   mic_slider.value = value
   mic_slider.level = value
end)
audio:connect_signal('source::name', function(_, name)
   mic_slider.label = name
end)

local music_slider = slider({
   label       = 'Player Unknown',
   icon_normal = beautiful.song,
   icon_hover  = beautiful.song,
   icon_click  = function() end,
   bar_action  = function(_, new) pctl:set_volume(new) end
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
