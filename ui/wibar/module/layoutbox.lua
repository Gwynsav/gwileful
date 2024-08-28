local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)

return function(s)
   -- Create an imagebox widget which will contain an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   local layout = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      {
         layout = wibox.layout.fixed.horizontal,
         {
            widget = wibox.container.background,
            bg     = color.bg3,
            forced_width = dpi(1)
         },
         {
            layout = wibox.layout.align.vertical,
            {
               widget = wibox.container.background,
               bg     = color.bg3,
               forced_height = dpi(1)
            },
            {
               widget  = wibox.container.margin,
               margins = dpi(6),
               {
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  height = dpi(9),
                  awful.widget.layoutbox({ screen = s })
               }
            },
            {
               widget = wibox.container.background,
               bg     = color.bg3,
               forced_height = dpi(1)
            }
         }
      },
      buttons = {
         awful.button(nil, 1, function() awful.layout.inc( 1) end),
         awful.button(nil, 3, function() awful.layout.inc(-1) end),
         awful.button(nil, 4, function() awful.layout.inc(-1) end),
         awful.button(nil, 5, function() awful.layout.inc( 1) end)
      }
   })
   layout:connect_signal('mouse::enter', function(self)
      self.bg = color.bg2
   end)
   layout:connect_signal('mouse::leave', function(self)
      self.bg = color.bg1
   end)

   return layout
end
