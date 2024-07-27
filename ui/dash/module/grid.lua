local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color   = require(beautiful.colorscheme)
local helpers = require('helpers')

return function()
   -- Returns a grid entry, with an icon, title, and body.
   -- @param args:
   --    - title: the entry title.
   --    - body: the entry body.
   --    - icon_normal: the icon in normal state.
   --    - icon_hover: the icon when hovered.
   --    - on_click: the action to execute on icon click.
   local function entry(args)
      local title = helpers.ctext(args.title, beautiful.font_bitm .. dpi(9), color.fg0)
      local body  = helpers.ctext(args.body,  beautiful.font_bitm .. dpi(9), color.fg1)

      local icon = wibox.widget({
         widget = wibox.widget.imagebox,
         image  = args.icon_normal,
         valign = 'center',
         forced_height = dpi(9),
         forced_width  = dpi(9),
         scaling_quality = 'nearest'
      })

      local widget = wibox.widget({
         widget = wibox.container.background,
         bg     = color.bg1,
         border_width = dpi(1),
         border_color = color.bg3,
         {
            widget  = wibox.container.margin,
            margins = dpi(8),
            {
               layout  = wibox.layout.fixed.horizontal,
               spacing = dpi(6),
               {
                  widget  = wibox.container.margin,
                  margins = dpi(4),
                  icon
               },
               {
                  layout = wibox.layout.fixed.vertical,
                  title,
                  body
               }
            }
         },
         buttons = {
            awful.button(nil, 1, args.on_click)
         }
      })
      widget:connect_signal('mouse::enter', function(self)
         self.border_color = color.accent
         icon.image        = args.icon_hover
      end)
      widget:connect_signal('mouse::leave', function(self)
         self.border_color = color.bg3
         icon.image        = args.icon_normal
      end)

      return widget
   end

   local network = entry({
      title = 'Network',
      body  = 'Wired connection',
      icon_normal = beautiful.network,
      icon_hover  = beautiful.network_hl,
      on_click = function() end
   })
   local bluetooth = entry({
      title = 'Bluetooth',
      body  = 'Powered on',
      icon_normal = beautiful.bluetooth,
      icon_hover  = beautiful.bluetooth_hl,
      on_click = function() end
   })

   return wibox.widget({
      layout = wibox.layout.grid,
      orientation = 'horizontal',
      expand = true,
      spacing = dpi(8),
      network,
      bluetooth
   })
end
