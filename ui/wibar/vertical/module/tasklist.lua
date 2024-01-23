local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color   = require(beautiful.colorscheme)
local helpers = require('helpers')

return function(s)
   -- Create a tasklist widget
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
      layout = wibox.layout.fixed.vertical,
      style = {
         disable_task_name = true,
         bg_normal   = color.bg0,
         bg_focus    = color.bg1,
         bg_urgent   = color.red .. '40',
         bg_minimize = color.bg0
      },
      widget_template = {
         widget = wibox.container.background,
         id     = 'background_role',
         {
            widget  = wibox.container.margin,
            margins = dpi(5),
            {
               widget = wibox.widget.imagebox,
               id     = 'image_role'
            }
         },
         set_image = function(self, icon)
            self:get_children_by_id('image_role')[1].image = icon
         end,
         create_callback = function(self, client)
            local icon = helpers.get_icon(nil, nil, client.name, client.class)
            if icon == helpers.DEFAULT_ICON and client.icon ~= nil then
               icon = client.icon
            end
            self.image = icon
         end
      }
   })
end
