local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local tabbed  = require('module.bling').widget.tabbed_misc
local helpers = require('helpers')
local color   = require(beautiful.colorscheme)
local icons   = require('theme.icons')

local _SIZE = dpi(9)
local _MARGIN = dpi(4)
local _EDGE = dpi(11) - _MARGIN

--- The titlebar to be used on normal clients.
return function(c)
   local function button(icon, hover, action)
      local widget = wibox.widget({
         widget = wibox.container.margin,
         margins = { left = _MARGIN, right = _MARGIN },
         {
            widget = helpers.ctext({
               text  = icon,
               font  = icons.font .. icons.size,
               align = 'center'
            }),
            id = 'image_role'
         },
         buttons = { awful.button(nil, 1, action) },
         set_col = function(self, col)
            self:get_children_by_id('image_role')[1].color = col
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
         self.col = hover
      end)
      widget:connect_signal('mouse::leave', function(self)
         self.col = color.fg0
      end)

      return widget
   end

   local tabs = tabbed.titlebar_indicator(c, {
      bg_color       = color.bg1 .. '80',
      bg_color_focus = color.transparent,
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
               button(icons['title_pin'], color.accent,
                  function()
                     c.sticky = not c.sticky
                  end
               )
            },
            {
               widget = wibox.container.background,
               bg     = color.bg3,
               forced_width = dpi(1)
            }
         },
         -- Middle
         {
            widget = wibox.container.background,
            bg     = color.bg0 .. '80',
            tabs
         },
         -- Right
         {
            layout  = wibox.layout.fixed.horizontal,
            {
               widget = wibox.container.background,
               bg     = color.bg3,
               forced_width = dpi(1)
            },
            {
               widget  = wibox.container.margin,
               margins = {
                  left   = _EDGE+1,
                  right  = _EDGE+1
               },
               {
                  layout  = wibox.layout.fixed.horizontal,
                  spacing = dpi(1),
                  button(icons['title_minimize'], color.accent,
                     function()
                        gears.timer.delayed_call(function()
                           c.minimized = not c.minimized
                        end)
                     end
                  ),
                  button(icons['title_maximize'], color.accent,
                     function()
                        c.maximized = not c.maximized
                        c:raise()
                     end
                  ),
                  button(icons['title_close'], color.red, function() c:kill() end)
               }
            }
         }
      }
   })

   local bottom = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      border_width = dpi(1),
      border_color = color.bg3,
      {
         layout = wibox.layout.fixed.horizontal,
         {
            widget = wibox.container.background,
            bg     = color.transparent,
            forced_width = dpi(48),
            buttons = {
               awful.button(nil, 1, function()
                  c:activate({ context = 'titlebar', action = 'mouse_move' })
               end),
               awful.button(nil, 3, function()
                  c:activate({ context = 'titlebar', action = 'mouse_resize' })
               end)
            }
         },
         {
            widget = wibox.container.background,
            bg     = color.bg3,
            forced_width = dpi(1)
         }
      }
   })

   local empty = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg3
   })

   awful.titlebar(c, { position = 'top',    size = dpi(33) }).widget = top
   awful.titlebar(c, { position = 'bottom', size = dpi(7)  }).widget = bottom
   awful.titlebar(c, { position = 'left',   size = dpi(1)  }).widget = empty
   awful.titlebar(c, { position = 'right',  size = dpi(1)  }).widget = empty
end
