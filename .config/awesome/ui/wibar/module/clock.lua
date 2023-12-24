local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)

return function()
   return wibox.widget {
      widget = wibox.container.background,
      bg     = color.bg1,
      {
         widget  = wibox.container.margin,
         margins = dpi(6),
         {
            layout = wibox.layout.fixed.vertical,
            {
               widget = wibox.widget.textclock,
               format = '<b>%H</b>',
               font   = beautiful.font_mono .. dpi(13),
               halign = 'center'
            },
            {
               widget = wibox.container.background,
               fg     = color.fg1,
               {
                  widget = wibox.widget.textclock,
                  format = '<b>%M</b>',
                  font   = beautiful.font_mono .. dpi(13),
                  halign = 'center'
               }
            }
         }
      }
   }
end
