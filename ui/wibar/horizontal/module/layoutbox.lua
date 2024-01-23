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
      fg     = color.fg0,
      {
         widget  = wibox.container.margin,
         margins = { left = dpi(4), right = dpi(4) },
         awful.widget.layoutbox({ screen = s })
      },
      buttons = {
         awful.button(nil, 1, function() awful.layout.inc( 1) end),
         awful.button(nil, 3, function() awful.layout.inc(-1) end),
         awful.button(nil, 4, function() awful.layout.inc(-1) end),
         awful.button(nil, 5, function() awful.layout.inc( 1) end)
      }
   })
   layout:connect_signal('mouse::enter', function(self)
      self.fg = color.accent
   end)
   layout:connect_signal('mouse::leave', function(self)
      self.fg = color.fg0
   end)

   return layout
end
