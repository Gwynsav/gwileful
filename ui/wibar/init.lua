local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color  = require(beautiful.colorscheme)
local module = require(... .. '.module')

return function(s)
   -- Create the wibox
   return awful.wibar({
      position = 'bottom',
      height   = dpi(36),
      screen   = s,
      widget   = {
         widget = wibox.container.background,
         bg     = color.bg3,
         {
            widget  = wibox.container.margin,
            margins = { top = dpi(1) },
            {
               widget = wibox.container.background,
               bg     = color.bg0,
               {
                  widget  = wibox.container.margin,
                  margins = {
                     left = dpi(24), right = dpi(24)
                  },
                  {
                     layout = wibox.layout.align.horizontal,
                     expand = 'none',
                     -- Left widgets.
                     {
                        widget  = wibox.container.margin,
                        margins = {
                           top = dpi(6), bottom = dpi(6)
                        },
                        {
                           layout  = wibox.layout.fixed.horizontal,
                           spacing = dpi(16),
                           module.launcher(),
                           module.taglist(s),
                           module.layoutbox(s)
                        }
                     },
                     -- Middle widgets.
                     {
                        widget   = wibox.container.constraint,
                        strategy = 'exact',
                        width    = dpi(awful.screen.focused().geometry.width * (4/9)),
                        module.tasklist(s)
                     },
                     -- Right widgets.
                     {
                        widget  = wibox.container.margin,
                        margins = {
                           top = dpi(6), bottom = dpi(6)
                        },
                        {
                           layout  = wibox.layout.fixed.horizontal,
                           spacing = dpi(12),
                           module.systray(),
                           module.status(),
                           module.clock()
                        }
                     }
                  }
               }
            }
         }
      }
   })
end
