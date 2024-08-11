local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color  = require(beautiful.colorscheme)
local audio  = require('signal.system.audio')
local helper = require('helpers')
local icons  = require('theme.icons')

-- local screen = awful.screen.focused()
local width, height, timeout = 200, 32, 3

return function(s)
   local icon = helper.ctext({
      text  = icons['audio_muted'],
      font  = icons.font .. icons.size,
      align = 'center'
   })

   local progress = wibox.widget({
      widget = wibox.widget.progressbar,
      background_color = color.bg1,
      color = color.fg0,
      margins = {
         left = dpi(9), right = dpi(9),
         top = dpi(6), bottom = dpi(6)
      }
   })

   local label = wibox.widget({
      widget = wibox.widget.textbox,
      text   = 'N/A'
   })

   local osd = wibox({
      x = (s.geometry.width - width) / 2,
      y = s.bar.height + beautiful.useless_gap,
      height  = height,
      width   = width,
      screen  = s,
      bg      = color.bg0,
      ontop   = true,
      visible = false,
      border_width = dpi(1),
      border_color = color.bg3,
      widget = {
         widget  = wibox.container.margin,
         margins = {
            left = dpi(12), right = dpi(12),
            top = dpi(9), bottom = dpi(9)
         },
         {
            layout = wibox.layout.align.horizontal,
            icon,
            progress,
            label
         }
      }
   })

   local timer = gears.timer({
      timeout = timeout,
      single_shot = true,
      callback = function()
         osd.visible = false
      end
   })

   local old = { mute = nil, level = nil, fresh = true }
   audio:connect_signal('sinks::default', function(_, default_sink)
      -- Sometimes, pactl gets pretty confused.
      if old.mute == default_sink.mute and old.level == default_sink.volume then
         return
      end
      -- Prevents the OSD from being shown on startup.
      if old.fresh then
         old.fresh = false
         return
      end

      -- Reset timer.
      if timer.started then
         timer:again()
      else
         osd.visible = true
         timer:start()
      end
      -- Update OSD.
      if default_sink.mute or default_sink.volume == 0 then
         icon.text = icons['audio_muted']
      elseif default_sink.volume >= 50 then
         icon.text = icons['audio_increase']
      else
         icon.text = icons['audio_decrease']
      end
      progress.value = default_sink.volume / 100
      label.text = default_sink.volume .. '%'
      -- Update reference values.
      old.mute  = default_sink.mute
      old.level = default_sink.volume
   end)

   return osd
end
