local require, client, awesome = require, client, awesome

local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local bling  = require('module.bling')
local color  = require(beautiful.colorscheme)
local user   = require('config.user')
local mod    = require('binds.mod')
local modkey = mod.modkey

local preview = user.lite == nil or not user.lite

return function(s)
   if preview then
      -- Enable and customize the tag preview widget.
      bling.widget.tag_preview.enable({
         show_client_content = true,
         scale = 0.125,
         honor_padding  = true,
         honor_workarea = true,
         placement_fn = function(c)
            awful.placement.next_to(c, {
               margins = { top = beautiful.useless_gap, left = dpi(40) },
               preferred_positions = 'bottom',
               preferred_anchors   = 'front',
               geometry            = s.bar
            })
         end
      })
   end

   -- Create the taglist.
   local tags = awful.widget.taglist({
      screen  = s,
      filter  = awful.widget.taglist.filter.all,
      buttons = {
         -- Left-clicking a tag changes to it.
         awful.button(nil, 1, function(t) t:view_only() end),
         -- Mod + Left-clicking a tag sends the currently focused client to it.
         awful.button({ modkey }, 1, function(t)
            if client.focus then
               client.focus:move_to_tag(t)
            end
         end),
         -- Right-clicking a tag makes its contents visible in the current one.
         awful.button(nil, 3, awful.tag.viewtoggle),
         -- Mod + Right-clicking a tag makes the currently focused client visible in it.
         awful.button({ modkey }, 3, function(t)
            if client.focus then
               client.focus:toggle_tag(t)
            end
         end),
         -- Mousewheel scrolling cycles through tags.
         awful.button(nil, 4, function(t) awful.tag.viewprev(t.screen) end),
         awful.button(nil, 5, function(t) awful.tag.viewnext(t.screen) end)
      },
      layout = {
         layout  = wibox.layout.fixed.horizontal,
         spacing = dpi(8)
      },
      style = {
         bg_focus    = color.accent,
         bg_occupied = color.fg2,
         bg_empty    = color.bg4 .. 'ac',
         bg_urgent   = color.red
      },

      -- The fun stuff.
      widget_template = {
         widget  = wibox.container.margin,
         -- The purpose of this margin widget is purely to fatten the hitbox of the tag
         -- lines, as to make them more mouse friendly.
         margins = {
            top = dpi(11), bottom = dpi(11)
         },
         {
            widget = wibox.container.background,
            id = 'background_role',
            -- Create the tag icon as an empty textbox.
            wibox.widget.textbox()
         },
         -- Create a callback to change its size with an animation depending
         -- on focus and occupation.
         create_callback = function(self, tag)
            local bar = self:get_children_by_id('background_role')[1]
            self.update = function()
               if tag.selected then
                  -- If the tag is focused:
                  bar.forced_width = dpi(48)
               elseif #tag:clients() > 0 then
                  -- If the tag is occupied:
                  bar.forced_width = dpi(32)
               else
                  -- If the tag is unoccupied and unfocused:
                  bar.forced_width = dpi(16)
               end
            end
            -- Generate the bar sizes once.
            self.update()

            if preview then
               -- Show a preview of the tag if it's hovered for a second.
               local visible, hovered = false, false
               local timer = gears.timer({
                  timeout     = 1,
                  single_shot = true,
                  callback    = function()
                     if not client.focus or not client.focus.fullscreen then
                        if not visible and hovered then
                           if #tag:clients() > 0 then
                              visible = true
                              awesome.emit_signal('bling::tag_preview::update', tag)
                              awesome.emit_signal("bling::tag_preview::visibility", s, true)
                           end
                        end
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
                     awesome.emit_signal("bling::tag_preview::visibility", s, false)
                  end
               end)
            end
         end,
         -- Then update on callback.
         update_callback = function(self)
            self.update()
         end
      }
   })

   return wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      border_width = dpi(1),
      border_color = color.bg3,
      {
         widget  = wibox.container.margin,
         margins = {
            left = dpi(11), right = dpi(11)
         },
         tags
      }
   })
end
