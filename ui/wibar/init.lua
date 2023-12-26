local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local module = require(... .. '.module')

return function(s)
   -- Create the wibox
   s.mywibox = awful.wibar({
      position = 'right',
      width    = dpi(48),
      screen   = s,
      widget   = {
         widget  = wibox.container.margin,
         margins = {
            left = dpi(6), right = dpi(6),
            top = dpi(12), bottom = dpi(12)
         },
         {
            layout = wibox.layout.align.vertical,
            expand = 'none',
            -- Left widgets.
            {
               layout  = wibox.layout.fixed.vertical,
               spacing = dpi(6),
               module.launcher(),
               module.taglist(s)
            },
            -- Middle widgets.
            module.tasklist(s),
            -- Right widgets.
            {
               layout  = wibox.layout.fixed.vertical,
               spacing = dpi(6),
               module.systray(),
               awful.widget.keyboardlayout(), -- Keyboard map indicator and switcher.
               module.clock(),
               module.layoutbox(s)
            }
         }
      }
   })
end
