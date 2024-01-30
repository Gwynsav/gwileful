local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color   = require(beautiful.colorscheme)

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
      layout = {
         layout  = wibox.layout.fixed.horizontal,
         spacing = dpi(8)
      },
      style = {
         -- Colors.
         fg_minimize = color.bg4,
         fg_normal   = color.fg2,
         fg_focus    = color.fg0,
         fg_urgent   = color.red,
         -- Styling.
         font         = beautiful.font_bitm .. dpi(9),
         disable_icon = true,
         maximized    = '[+]',
         minimized    = '[-]',
         sticky       = '[*]',
         floating     = '[~]',
         ontop        = '',
         above        = ''
      },
      widget_template = {
         widget   = wibox.container.constraint,
         strategy = 'max',
         width    = dpi(128),
         {
            widget = wibox.container.background,
            id     = 'background_role',
            {
               widget  = wibox.container.margin,
               margins = dpi(5),
               {
                  widget = wibox.widget.textbox,
                  id     = 'text_role'
               }
            }
         }
      }
   })
end
