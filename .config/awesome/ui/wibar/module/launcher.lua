local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)

-- Create a launcher widget. Opens the Awesome menu when clicked.
return function()
   local widget = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      {
         widget  = wibox.container.margin,
         margins = {
            left = dpi(7), right = dpi(7),
            top = dpi(14), bottom = dpi(14)
         },
         awful.widget.launcher({
            image = beautiful.awesome_icon,
            menu  = require('ui.menu').main
         })
      }
   })
   widget:connect_signal('mouse::enter', function()
      widget.bg = color.bg4 .. '56'
   end)
   widget:connect_signal('mouse::leave', function()
      widget.bg = color.bg1
   end)

   return widget
end
