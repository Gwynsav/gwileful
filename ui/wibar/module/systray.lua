local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local helpers = require('helpers')
local color = require(beautiful.colorscheme)
local icons = require('theme.icons')

return function()
   -- The systray itself.
   local systray = wibox.widget({
      widget  = wibox.container.margin,
      margins = dpi(3),
      visible = false,
      wibox.widget.systray()
   })

   -- The arrow image.
   local switch = helpers.ctext({
      text  = icons['arrow_left'],
      font  = icons.font .. icons.size,
      align = 'center'
   })

   -- Widget containing both, when hovered, lights up the switch and when clicked,
   -- switches states and changes the icon's direction.
   local widget = wibox.widget({
      layout  = wibox.layout.fixed.horizontal,
      systray,
      {
         widget = wibox.container.background,
         bg     = color.transparent,
         id     = 'bg_role',
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(7), bottom = dpi(7),
               left = dpi(6), right = dpi(6)
            },
            switch
         },
         buttons = {
            awful.button(nil, 1, function()
               if systray.visible then
                  systray.visible = false
                  switch.text = icons['arrow_left']
               else
                  systray.visible = true
                  switch.text = icons['arrow_right']
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
