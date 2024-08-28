local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local color   = require(beautiful.colorscheme)
local helpers = require('helpers')
local icons   = require('theme.icons')

-- Create a launcher widget. Opens the Awesome menu when clicked.
return function(s)
   local arrow = helpers.ctext({
      text  = icons['arrow_down'],
      font  = icons.font .. icons.size,
      align = 'center'
   })

   local widget = wibox.widget({
      widget = wibox.container.background,
      shape = function(cr, w, h)
         gears.shape.circle(cr, w, h)
      end,
      {
         layout = wibox.layout.stack,
         {
            widget = wibox.widget.imagebox,
            image = beautiful.pfp
         },
         {
            widget = wibox.container.background,
            visible = false,
            bg = color.bg1 .. 'C0',
            id = 'hover_over',
            arrow
         }
      },
      buttons = {
         awful.button(nil, 1, function()
            s.dash:toggle()
            arrow.text = s.dash.visible and icons['arrow_up'] or icons['arrow_down']
         end)
      },
      set_hover = function(self, bool)
         self:get_children_by_id('hover_over')[1].visible = bool
      end
   })
   widget:connect_signal('mouse::enter', function(self)
      self.hover = true
      arrow.direction = s.dash.visible and 'north' or 'south'
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.hover = false
   end)

   return widget
end
