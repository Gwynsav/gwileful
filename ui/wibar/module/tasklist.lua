local require, awesome = require, awesome

local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local bling = require('module.bling')
local color = require(beautiful.colorscheme)
local user  = require('config.user')

return function(s)
   if not user.lite or user.lite == nil then
      -- Enable and customize the task preview widget.
      bling.widget.task_preview.enable({
         placement_fn = function(c)
            awful.placement.next_to(c, {
               margins = { top = beautiful.useless_gap },
               preferred_positions = 'bottom',
               preferred_anchors   = 'middle',
               geometry            = s.bar
            })
         end,
         structure = {
            widget = wibox.container.background,
            bg     = color.bg1,
            border_width = dpi(1),
            border_color = color.bg3,
            {
               widget  = wibox.container.margin,
               margins = {
                  top = dpi(6), bottom = dpi(8),
                  left = dpi(8), right = dpi(8)
               },
               {
                  layout  = wibox.layout.fixed.vertical,
                  spacing = dpi(4),
                  {
                     widget = wibox.widget.textbox,
                     id     = 'name_role'
                  },
                  {
                     widget = wibox.widget.imagebox,
                     resize = true,
                     valign = 'center',
                     halign = 'center',
                     id     = 'image_role'
                  }
               }
            }
         }
      })
   end

   -- Create a tasklist widget.
   return awful.widget.tasklist({
      screen  = s,
      filter  = awful.widget.tasklist.filter.currenttags,
      buttons = {
         -- Left-clicking a client indicator minimizes it if it's unminimized, or
         -- unminimizes it if it's minimized.
         awful.button(nil, 1, function(c)
            c:activate({ context = 'tasklist', action = 'toggle_minimization' })
         end),
         -- Right-clicking a client indicator shows the list of all open clients in all
         -- visible tags.
         awful.button(nil, 3, function() awful.menu.client_list({
            theme = { width = 250 } })
         end),
         -- Mousewheel scrolling cycles through clients.
         awful.button(nil, 4, function() awful.client.focus.byidx(-1) end),
         awful.button(nil, 5, function() awful.client.focus.byidx( 1) end)
      },
      layout = {
         layout = wibox.layout.flex.horizontal
      },
      style = {
         -- Colors.
         bg_minimize = color.bg1,
         fg_minimize = color.bg4,
         bg_normal   = color.bg1,
         fg_normal   = color.fg2,
         bg_focus    = color.transparent,
         fg_focus    = color.accent,
         bg_urgent   = color.red,
         fg_urgent   = color.bg0,
         -- Styling.
         font         = beautiful.font,
         disable_icon = true,
         maximized    = '[+]',
         minimized    = '[-]',
         sticky       = '[*]',
         floating     = '[~]',
         ontop        = '[^]',
         above        = '[!]'
      },
      widget_template = {
         widget = wibox.container.background,
         id     = 'background_role',
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(7), bottom = dpi(7),
               left = dpi(13), right = dpi(13)
            },
            {
               widget = wibox.widget.textbox,
               valign = 'center',
               id     = 'text_role'
            }
         },
         create_callback = function(self, task)
            -- Show a preview of the task if it's hovered for a second.
            local visible, hovered = false, false
            local timer   = gears.timer({
               timeout     = 1,
               single_shot = true,
               callback    = function()
                  if not visible and hovered then
                     visible = true
                     awesome.emit_signal("bling::task_preview::visibility", s, true, task)
                  end
               end
            })
            self:connect_signal('mouse::enter', function()
               hovered = true
               timer:start()
            end)
            self:connect_signal('mouse::leave', function()
               hovered = false
               if visible then
                  visible = false
                  timer:stop()
                  awesome.emit_signal("bling::task_preview::visibility", s, false, task)
               end
            end)
         end
      }
   })
end
