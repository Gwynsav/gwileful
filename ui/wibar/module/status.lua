local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi   = beautiful.xresources.apply_dpi
local color = require(beautiful.colorscheme)

local audio_off =
   gears.filesystem.get_configuration_dir() .. 'theme/assets/status/volume/off.png'

local audio = wibox.widget({
   widget  = wibox.container.margin,
   margins = {
      top = dpi(4), bottom = dpi(4),
      left = dpi(2), right = dpi(2)
   },
   {
      widget = wibox.widget.imagebox,
      image  = gears.color.recolor_image(audio_off, color.red),
      scaling_quality = 'nearest',
      forced_height = dpi(9),
      forced_width = dpi(9),
      valign = 'center',
      halign = 'center'
   },
   visible = false
})
awesome.connect_signal('audio::update', function(_, mute)
   audio.visible = (mute == 1)
end)

return function()
   return wibox.widget({
      layout = wibox.layout.fixed.horizontal,
      awful.widget.keyboardlayout,
      audio
   })
end
