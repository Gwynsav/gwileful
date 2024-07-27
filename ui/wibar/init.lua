local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color  = require(beautiful.colorscheme)
local module = require(... .. '.module')

return function(s)
   -- Create the wibox
   return awful.wibar({
      position = 'top',
      height   = dpi(35),
      screen   = s,
      widget   = {
         widget = wibox.container.background,
         bg     = color.bg0,
         {
            widget  = wibox.container.margin,
            margins = {
               left = dpi(16), right = dpi(16)
            },
            {
               layout = wibox.layout.align.horizontal,
               expand = 'none',
               -- Left widgets.
               {
                  layout  = wibox.layout.fixed.horizontal,
                  spacing = dpi(16),
                  module.clock(),
                  {
                     widget   = wibox.container.constraint,
                     strategy = 'exact',
                     width    = dpi(awful.screen.focused().geometry.width * 0.3),
                     module.tasklist(s)
                  }
               },
               -- Middle widgets.
               {
                  widget = wibox.container.margin,
                  margins = {
                     top = dpi(6), bottom = dpi(6)
                  },
                  module.taglist(s)
               },
               -- Right widgets.
               {
                  layout  = wibox.layout.fixed.horizontal,
                  spacing = dpi(12),
                  {
                     widget  = wibox.container.margin,
                     margins = {
                        top = dpi(6), bottom = dpi(6)
                     },
                     module.systray()
                  },
                  module.status(),
                  {
                     widget  = wibox.container.margin,
                     margins = { top = dpi(6), bottom = dpi(6) },
                     {
                        layout  = wibox.layout.fixed.horizontal,
                        spacing = dpi(12),
                        module.launcher(s),
                        module.layoutbox(s),
                        module.dash(s)
                     }
                  }
               }
            }
         }
      }
   })
end
