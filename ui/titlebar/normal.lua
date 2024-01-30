local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local tabbed = require('module.bling').widget.tabbed_misc

--- The titlebar to be used on normal clients.
return function(c)
   -- Padding on the sides for the buttons.
   local edge = wibox.widget({
      widget = wibox.container.margin,
      margins = { left = dpi(7), right = dpi(8) }
   })

   -- Forgive me father for I have sinned.
   local function button(focus, normal, hover_color, margin, leftmost, rightmost, action)
      local widget = wibox.widget({
         widget = wibox.container.background,
         bg     = color.transparent,
         {
            widget  = wibox.container.margin,
            margins = {
               top    = dpi(margin),
               bottom = dpi(margin),
               left   = dpi(4),
               right  = dpi(4)
            },
            id = 'margin_role',
            {
               widget = wibox.widget.imagebox,
               image  = normal,
               id     = 'image_role',
               scaling_quality = 'nearest'
            }
         },
         buttons = { awful.button(nil, 1, action) },
         set_image = function(self, image)
            self:get_children_by_id('image_role')[1].image = image
         end,
         set_margins = function(self, margins)
            self:get_children_by_id('margin_role')[1].margins = margins
         end
      })

      -- Changes the icons for a lighter version when the client is focused. Reverts on
      -- focus loss.
      client.connect_signal('property::active', function()
         if c.active then
            widget.image = focus
         else
            widget.image = normal
         end
      end)

      -- Adjust paddings and colors when hovering. The paddings for the titlebar only
      -- change is either edge is larger than 0.
      widget:connect_signal('mouse::enter', function(self)
         self.bg = hover_color
         self.margins = dpi(margin)

         if leftmost or rightmost then
            edge.margins = {
               left  = leftmost  and 0 or dpi(7),
               right = rightmost and 0 or dpi(8)
            }
         end
      end)
      widget:connect_signal('mouse::leave', function(self)
         self.bg = color.transparent
         self.margins = {
            top    = dpi(margin),
            bottom = dpi(margin),
            left   = dpi(4),
            right  = dpi(4)
         }

         if leftmost or rightmost then
            edge.margins = {
               left  = dpi(7),
               right = dpi(8)
            }
         end
      end)

      return widget
   end

   local tabs = tabbed.titlebar_indicator(c, {
      layout = wibox.layout.fixed.horizontal,
      layout_spacing = dpi(12),
      widget_template = {
         widget = wibox.container.background,
         {
            widget   = wibox.container.constraint,
            strategy = 'max',
            width    = dpi(120),
            {
               widget = wibox.container.margin,
               margins = { top = dpi(10), bottom = dpi(10) },
               {
                  widget = wibox.widget.textbox,
                  id     = 'text_role'
               }
            }
         },
         create_callback = function(self, client, group)
            if client == group.clients[group.focused_idx] then
               self.fg = color.fg0
            else
               self.fg = color.fg2 .. 'cc'
            end
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
         widget = edge,
         {
            layout = wibox.layout.align.horizontal,
            expand = 'none',
            -- Left
            {
               layout  = wibox.layout.fixed.horizontal,
               spacing = dpi(10),
               button(beautiful.titlebar_pin_focus, beautiful.titlebar_pin_normal,
                  color.bg4 .. '6f', 11, true, false, function()
                  c.sticky = not c.sticky
               end),
               tabs
            },
            -- Middle
            nil,
            -- Right
            {
               layout  = wibox.layout.fixed.horizontal,
               button(beautiful.titlebar_min_focus, beautiful.titlebar_min_normal,
                  color.bg4 .. '6f', 12, false, false, function()
                  gears.timer.delayed_call(function()
                     c.minimized = not c.minimized
                  end)
               end),
               button(beautiful.titlebar_max_focus, beautiful.titlebar_max_normal,
                  color.bg4 .. '6f', 12, false, false, function()
                  c.maximized = not c.maximized
                  c:raise()
               end),
               button(beautiful.titlebar_close_focus, beautiful.titlebar_close_normal,
                  color.red .. '6f', 12, false, true, function()
                  c:kill()
               end)
            }
         }
      }
   })

   local empty = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg3
   })

   awful.titlebar(c, { position = 'top',    size = dpi(34) }).widget = top
   awful.titlebar(c, { position = 'bottom', size = dpi(1)  }).widget = empty
   awful.titlebar(c, { position = 'left',   size = dpi(1)  }).widget = empty
   awful.titlebar(c, { position = 'right',  size = dpi(1)  }).widget = empty
end
