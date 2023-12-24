local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color  = require(beautiful.colorscheme)
local mod    = require('binds.mod')
local modkey = mod.modkey

return function(s)
   return wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      {
         widget  = wibox.container.margin,
         margins = dpi(16),
         awful.widget.taglist({
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
               -- Mod + Right-clicking a tag makes the currently focused client visible 
               -- in it.
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
               layout  = wibox.layout.fixed.vertical,
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
               -- Create the tag icon as an empty textbox.
               widget = wibox.container.background,
               id = 'background_role',
               forced_width = dpi(2),
               wibox.widget.textbox(),
               -- Create a callback to change its size with an animation depending
               -- on focus and occupation.
               create_callback = function(self, tag)
                  local bar = self:get_children_by_id('background_role')[1]
                  self.update = function()
                     if tag.selected then
                        -- If the tag is focused:
                        bar.forced_height = dpi(38)
                     elseif #tag:clients() > 0 then
                        -- If the tag is occupied:
                        bar.forced_height = dpi(28)
                     else
                        -- If the tag is unoccupied and unfocused:
                        bar.forced_height = dpi(18)
                     end
                  end
                  -- Generate the bar sizes once.
                  self.update()
               end,
               -- Then update on callback.
               update_callback = function(self)
                  self.update()
               end
            }
         })
      }
   })
end
