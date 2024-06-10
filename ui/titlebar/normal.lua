local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local tabbed = require('module.bling').widget.tabbed_misc

local _SIZE = dpi(9)
local _MARGIN = dpi(4)
local _EDGE = dpi(11) - _MARGIN

--- The titlebar to be used on normal clients.
return function(c)
   local function button(regular, hover, action)
      local widget = wibox.widget({
         widget = wibox.container.background,
         bg     = color.transparent,
         {
            widget = wibox.container.margin,
            margins = { left = _MARGIN, right = _MARGIN },
            {
               widget = wibox.widget.imagebox,
               image  = regular,
               id     = 'image_role',
               valign = 'center',
               forced_height   = _SIZE,
               forced_width    = _SIZE,
               scaling_quality = 'nearest'
            }
         },
         buttons = { awful.button(nil, 1, action) },
         set_image = function(self, image)
            self:get_children_by_id('image_role')[1].image = image
         end
      })

      -- Changes the icons for a lighter version when the client is focused. Reverts on
      -- focus loss.
      client.connect_signal('property::active', function()
         if c.active then
            widget.opacity = 1
         else
            widget.opacity = 0.66
         end
      end)

      -- Adjust colors when hovering.
      widget:connect_signal('mouse::enter', function(self)
         self.image = hover
      end)
      widget:connect_signal('mouse::leave', function(self)
         self.image = regular
      end)

      return widget
   end

   local tabs = tabbed.titlebar_indicator(c, {
      bg_color       = color.bg2,
      bg_color_focus = color.bg2 .. '80',
      fg_color       = color.fg0 .. 'AB',
      fg_color_focus = color.accent,
      layout = wibox.layout.flex.horizontal,
      layout_spacing = 0,
      widget_template = {
         widget = wibox.container.background,
         id     = 'bg_role',
         {
            widget = wibox.container.margin,
            margins = {
               left = _SIZE+2, right = _SIZE+2,
               top = _SIZE+2, bottom = _SIZE+2
            },
            {
               widget = wibox.widget.textbox,
               valign = 'center',
               id     = 'text_role'
            }
         },
         create_callback = function(self, client, _)
            self.text = client.name
         end,
         update_callback = function(self, client, group)
            self.create_callback(self, client, group)
         end
      }
   })

   local top = wibox.widget({
      widget  = wibox.container.background,
      bg      = color.bg1,
      border_width = dpi(1),
      border_color = color.bg3,
      buttons = {
         awful.button(nil, 1, function()
            c:activate({ context = 'titlebar', action = 'mouse_move' })
         end),
         awful.button(nil, 3, function()
            c:activate({ context = 'titlebar', action = 'mouse_resize' })
         end)
      },
      {
         layout = wibox.layout.align.horizontal,
         expand = 'outer',
         -- Left
         {
            layout  = wibox.layout.fixed.horizontal,
            {
               widget  = wibox.container.margin,
               margins = {
                  left   = _EDGE+1,
                  right  = _EDGE+1
               },
               button(beautiful.titlebar_pin_focus, beautiful.titlebar_pin_hover,
                  function()
                     c.sticky = not c.sticky
                  end
               )
            },
            tabs
         },
         -- Middle
         nil,
         -- Right
         {
            widget  = wibox.container.margin,
            margins = {
               left   = _EDGE+1,
               right  = _EDGE+1
            },
            {
               layout  = wibox.layout.fixed.horizontal,
               spacing = dpi(1),
               button(beautiful.titlebar_min_focus, beautiful.titlebar_min_hover,
                  function()
                     gears.timer.delayed_call(function()
                        c.minimized = not c.minimized
                     end)
                  end
               ),
               button(beautiful.titlebar_max_focus, beautiful.titlebar_max_hover,
                  function()
                     c.maximized = not c.maximized
                     c:raise()
                  end
               ),
               button(beautiful.titlebar_close_focus, beautiful.titlebar_close_hover,
                  function() c:kill() end)
            }
         }
      }
   })

   local empty = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg3
   })

   awful.titlebar(c, { position = 'top',    size = dpi(33) }).widget = top
   awful.titlebar(c, { position = 'bottom', size = dpi(1)  }).widget = empty
   awful.titlebar(c, { position = 'left',   size = dpi(1)  }).widget = empty
   awful.titlebar(c, { position = 'right',  size = dpi(1)  }).widget = empty
end
