local require = require

local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color  = require(beautiful.colorscheme)
local widget = require('widget')
local icons  = require('theme.icons')
local user   = require('config.user')

-- Create a launcher widget. Opens the Awesome menu when clicked.
return function(s)
   local arrow = widget.textbox.colored({
      text  = icons['arrow_down'],
      font  = icons.font .. icons.size,
      align = 'center'
   })

   local idle
   if not user.lite or user.lite == nil then
      idle = wibox.widget({
         widget = wibox.widget.imagebox,
         image  = beautiful.pfp,
         vertical_fit_policy   = 'fit',
         horizontal_fit_policy = 'fit'
      })
   else
      idle = wibox.widget({
         widget  = wibox.container.margin,
         margins = {
            left = dpi(7), right = dpi(7)
         },
         widget.textbox.colored({
            text  = icons['util_hamburger'],
            font  = icons.font .. icons.size
         })
      })
   end

   local w = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      shape  = function(cr, w, h)
         gears.shape.circle(cr, w, h)
      end,
      forced_height = dpi(23),
      forced_width = dpi(23),
      {
         layout = wibox.layout.stack,
         idle,
         {
            widget = wibox.container.background,
            visible = false,
            bg = color.bg2 .. 'C0',
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
   w:connect_signal('mouse::enter', function(self)
      self.hover = true
      arrow.direction = s.dash.visible and 'north' or 'south'
   end)
   w:connect_signal('mouse::leave', function(self)
      self.hover = false
   end)

   return w
end
