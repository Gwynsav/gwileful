local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local user  = require('config.user')
local color = require(beautiful.colorscheme)

-- Create a launcher widget. Opens the Awesome menu when clicked.
return function(s)
   local arrow = wibox.widget({
      widget = wibox.container.rotate,
      direction = 'south',
      {
         widget = wibox.widget.imagebox,
         image  = beautiful.arrow,
         forced_height = dpi(9),
         forced_width  = dpi(9),
         scaling_quality = 'nearest'
      }
   })

   local widget = wibox.widget({
      layout = wibox.layout.stack,
      {
         widget = wibox.widget.imagebox,
         clip_shape = gears.shape.circle,
         image = user.pfp or beautiful.def_pfp
      },
      {
         widget = wibox.container.background,
         shape = function(cr, w, h)
            gears.shape.circle(cr, w, h)
         end,
         visible = false,
         bg = color.bg1 .. 'C0',
         id = 'hover_over',
         {
            widget = wibox.container.margin,
            margins = dpi(7),
            arrow
         }
      },
      buttons = {
         awful.button(nil, 1, function()
            require('ui.dash'):show()
         end)
      },
      set_hover = function(self, bool)
         self:get_children_by_id('hover_over')[1].visible = bool
      end
   })
   widget:connect_signal('mouse::enter', function(self)
      self.hover = true
      if s.dash.visible then
         arrow.direction = 'north'
      else
         arrow.direction = 'south'
      end
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.hover = false
   end)

   return widget
end
