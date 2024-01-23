local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)

return function()
   -- The systray itself.
   local systray = wibox.widget({
      widget  = wibox.container.margin,
      margins = dpi(6),
      visible = false,
      {
         widget     = wibox.widget.systray,
         horizontal = false
      }
   })

   -- The arrow image.
   local switch = wibox.widget({
      widget = wibox.container.rotate,
      {
         widget = wibox.widget.imagebox,
         image  = beautiful.systray_arrow
      }
   })

   -- Widget containing both, when hovered, lights up the switch and when clicked,
   -- switches states and changes the icon's direction.
   local widget = wibox.widget({
      layout  = wibox.layout.fixed.vertical,
      systray,
      {
         widget = wibox.container.background,
         bg     = color.transparent,
         id     = 'bg_role',
         {
            widget  = wibox.container.margin,
            margins = {
               left = dpi(12), right = dpi(12),
               top = dpi(6), bottom = dpi(6)
            },
            switch
         },
         buttons = {
            awful.button(nil, 1, function()
               if systray.visible then
                  systray.visible  = false
                  switch.direction = 'north'
               else
                  systray.visible  = true
                  switch.direction = 'south'
               end
            end)
         }
      },
      set_bg = function(self, bg)
         self:get_children_by_id('bg_role')[1].bg = bg
      end
   })
   widget:connect_signal('mouse::enter', function(self)
      self.bg = color.bg4 .. '56'
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.bg = color.transparent
   end)

   return widget
end
