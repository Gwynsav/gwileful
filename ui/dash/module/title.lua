local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi   = beautiful.xresources.apply_dpi
local color = require(beautiful.colorscheme)
local icons = require('theme.icons')

return function()
   return wibox.widget({
      layout = wibox.layout.fixed.vertical,
      {
         widget = wibox.container.background,
         bg     = color.bg3,
         forced_height = dpi(1)
      },
      {
         widget = wibox.container.background,
         bg     = color.bg1,
         {
            layout = wibox.layout.align.horizontal,
            {
               widget  = wibox.container.margin,
               margins = {
                  top = dpi(6), bottom = dpi(6),
                  left = dpi(10), right = dpi(10)
               },
               {
                  widget = wibox.widget.textbox,
                  text   = 'Quick Settings Menu',
               }
            },
            nil,
            {
               layout = wibox.layout.fixed.horizontal,
               {
                  widget = wibox.container.background,
                  bg = color.bg3,
                  forced_width = dpi(1)
               },
               {
                  widget = wibox.container.margin,
                  margins = {
                     left = dpi(8), right = dpi(8),
                     top = dpi(6), bottom = dpi(6)
                  },
                  {
                     widget = wibox.widget.textbox,
                     text   = icons['util_hamburger'],
                     font   = icons.font .. icons.size
                  }
               }
            }
         }
      }
   })
end
