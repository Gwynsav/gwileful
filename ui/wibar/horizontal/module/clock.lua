local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)

return function()
   return wibox.widget {
      layout  = wibox.layout.fixed.horizontal,
      spacing = dpi(8),
      {
         widget = wibox.widget.textclock,
         format = '%H:%M',
         font   = beautiful.font_bitm .. dpi(9)
      },
      {
         widget = wibox.container.background,
         fg     = color.fg2 .. '7f',
         {
            widget = wibox.widget.textbox,
            text   = '//',
            font   = beautiful.font_bitm .. dpi(9)
         }
      },
      {
         widget = wibox.widget.textclock,
         format = '<i>%B %d</i>',
         font   = beautiful.font_bitm .. dpi(9)
      }
   }
end
