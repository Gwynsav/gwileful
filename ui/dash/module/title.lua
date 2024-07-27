local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi   = beautiful.xresources.apply_dpi
local color = require(beautiful.colorscheme)

local function button(icon, icon_ng, action)
   local widget = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg0 .. '60',
      {
         widget = wibox.container.margin,
         margins = {
            left = dpi(8), right = dpi(8),
            top = dpi(6), bottom = dpi(6)
         },
         {
            widget = wibox.widget.imagebox,
            image  = icon,
            halign = 'center',
            valign = 'center',
            forced_height = dpi(9),
            forced_width  = dpi(9),
            scaling_quality = 'nearest',
            id = 'image_role'
         }
      },
      buttons = { awful.button(nil, 1, action) },
      set_image = function(self, image)
         self:get_children_by_id('image_role')[1].image = image
      end
   })
   widget:connect_signal('mouse::enter', function(self)
      self.image = icon_ng
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.image = icon
   end)
   return widget
end

return function()
   return wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      {
         layout = wibox.layout.align.horizontal,
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(6), bottom = dpi(6),
               left = dpi(10), right = dpi(10)
            },
            {
               widget = wibox.widget.textbox,
               text   = 'Quick Settings Menu',
            }
         },
         nil,
         {
            layout = wibox.layout.fixed.horizontal,
            button(beautiful.hamburger, beautiful.hamburger, function() end)
         }
      }
   })
end
