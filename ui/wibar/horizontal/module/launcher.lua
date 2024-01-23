local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)

-- Create a launcher widget. Opens the Awesome menu when clicked.
return function()
   local widget = wibox.widget({
      widget = wibox.container.background,
      fg     = color.fg0,
      {
         widget  = wibox.container.margin,
         margins = {
            bottom = dpi(7), top = dpi(7),
            left = dpi(4), right = dpi(4)
         },
         {
            widget = wibox.widget.textbox,
            font   = beautiful.font_bitm .. dpi(9),
            text   = 'menu'
         }
      },
      buttons = {
         awful.button(nil, 1, function()
            require('naughty').notification({
               title   = '<i>Oh, oh</i>',
               message = 'Dashboard is TODO!'
            })
         end)
      }
   })
   widget:connect_signal('mouse::enter', function(self)
      self.fg = color.accent
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.fg = color.fg0
   end)

   return widget
end
