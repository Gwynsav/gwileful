local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi   = beautiful.xresources.apply_dpi
local color = require(beautiful.colorscheme)

local audio = require('signal.system.audio')

local audio_widget = wibox.widget({
   widget  = wibox.container.margin,
   margins = {
      top = dpi(4), bottom = dpi(4),
      left = dpi(2), right = dpi(2)
   },
   {
      widget = wibox.widget.imagebox,
      image  = beautiful.vol_off,
      scaling_quality = 'nearest',
      forced_height = dpi(9),
      forced_width = dpi(9),
      valign = 'center',
      halign = 'center'
   },
   visible = false
})
audio:connect_signal('sink::get', function(_, mute, _)
   audio_widget.visible = mute
end)

return function()
   return wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      {
         widget  = wibox.container.margin,
         margins = dpi(6),
         {
            layout = wibox.layout.fixed.horizontal,
            audio_widget,
            awful.widget.keyboardlayout
         }
      }
   })
end
