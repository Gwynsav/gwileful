local require, client = require, client

local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local tabbed = require('module.bling').widget.tabbed_misc
local widget = require('widget')
local color  = require(beautiful.colorscheme)
local icons  = require('theme.icons')

--- The titlebar to be used on normal clients.
return function(c)
   local function button(icon, hover, action)
      local w = wibox.widget({
         widget = wibox.container.background,
         bg     = color.bg2 .. '90',
         border_width = dpi(1),
         border_color = color.bg3,
         {
            widget = wibox.container.margin,
            margins = { left = dpi(5), right = dpi(5) },
            {
               widget = widget.textbox.colored({
                  text  = icon,
                  font  = icons.font .. icons.size,
                  align = 'center'
               }),
               id = 'image_role'
            }
         },
         buttons = { awful.button(nil, 1, action) },
         set_fg_col = function(self, fg)
            self:get_children_by_id('image_role')[1].color = fg
         end,
         set_bd_col = function(self, bd)
            self.border_color = bd
         end,
         set_bg_col = function(self, bg)
            self.bg = bg
         end
      })

      -- Changes the icons for a lighter version when the client is focused. Reverts on
      -- focus loss.
      client.connect_signal('property::active', function()
         if c.active then
            w.opacity = 1
         else
            w.opacity = 0.66
         end
      end)

      -- Adjust colors when hovering.
      w:connect_signal('mouse::enter', function(self)
         self.fg_col = hover
         self.bd_col = hover
         self.bg_col = color.bg2
      end)
      w:connect_signal('mouse::leave', function(self)
         self.fg_col = color.fg0
         self.bd_col = color.bg3
         self.bg_col = color.bg2 .. '90'
      end)

      return w
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
               left = dpi(11), right = dpi(11),
               top = dpi(11), bottom = dpi(11)
            },
            {
               widget = wibox.widget.textbox,
               valign = 'center',
               id     = 'text_role'
            }
         },
         create_callback = function(self, window, _)
            self.text = window.name
         end,
         update_callback = function(self, window, group)
            self.create_callback(self, window, group)
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
               margins = dpi(6),
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
               margins = dpi(7),
               {
                  layout  = wibox.layout.fixed.horizontal,
                  spacing = dpi(2),
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
