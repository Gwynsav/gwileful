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
      layout = wibox.layout.fixed.horizontal,
      visible = false,
      {
         widget = wibox.container.background,
         bg     = color.bg3,
         forced_width = dpi(1)
      },
      {
         layout = wibox.layout.fixed.vertical,
         {
            widget = wibox.container.background,
            bg     = color.bg3,
            forced_height = dpi(1)
         },
         {
            widget = wibox.container.background,
            bg     = color.bg1,
            {
               widget  = wibox.container.margin,
               margins = dpi(3),
               {
                  widget = wibox.container.constraint,
                  strategy = 'exact',
                  height = dpi(15),
                  wibox.widget.systray()
               }
            }
         },
         {
            widget = wibox.container.background,
            bg     = color.bg3,
            forced_height = dpi(1)
         }
      }
   })

   -- The arrow image.
   local switch = helpers.ctext({
      text  = icons['arrow_left'],
      font  = icons.font .. icons.size,
      align = 'center'
   })
   local switchbox = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      border_width = dpi(1),
      border_color = color.bg3,
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
   })
   switchbox:connect_signal('mouse::enter', function(self)
      self.bg = color.bg2
   end)
   switchbox:connect_signal('mouse::leave', function(self)
      self.bg = color.bg1
   end)

   -- When hovered, lights up the switch and when clicked, switches states and changes
   -- the icon's direction.
   return wibox.widget({
      layout  = wibox.layout.fixed.horizontal,
      systray,
      switchbox
   })
end
