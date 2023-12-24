local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)

--- The titlebar to be used on normal clients.
return function(c)
   local background = wibox.widget {
      widget  = wibox.container.background,
      bg      = color.bg1,
      fg      = color.fg1,
      buttons = {
         awful.button(nil, 1, function()
            c:activate({ context = 'titlebar', action = 'mouse_move' })
         end),
         awful.button(nil, 3, function()
            c:activate({ context = 'titlebar', action = 'mouse_resize' })
         end)
      }
   }

   -- Creates a client button.
   local function button(focus, normal, action)
      local widget = wibox.widget({
         widget     = wibox.widget.imagebox,
         image      = normal,
         buttons    = { awful.button(nil, 1, action) }
      })
      client.connect_signal('property::active', function()
         if c.active then
            widget.image  = focus
            background.fg = color.fg0
         else
            widget.image  = normal
            background.fg = color.fg1
         end
      end)

      return widget
   end

   local top = wibox.widget({
      widget = background,
      {
         widget  = wibox.container.margin,
         margins = {
            top = dpi(11), bottom = dpi(11),
            left = dpi(13), right = dpi(11)
         },
         {
            layout = wibox.layout.align.horizontal,
            expand = 'none',
            -- Left
            {
               widget = awful.titlebar.widget.titlewidget(c),
               font   = beautiful.font_bitm .. dpi(9)
            },
            -- Middle
            nil,
            -- Right
            {
               widget   = wibox.container.constraint,
               strategy = 'min',
               width    = dpi(40),
               {
                  layout  = wibox.layout.fixed.horizontal,
                  spacing = dpi(4),
                  button(beautiful.titlebar_min_focus,
                     beautiful.titlebar_min_normal,function()
                     gears.timer.delayed_call(function()
                        c.minimized = not c.minimized
                     end)
                  end),
                  button(beautiful.titlebar_max_focus,
                     beautiful.titlebar_max_normal, function()
                     c.maximized = not c.maximized
                     c:raise()
                  end),
                  button(beautiful.titlebar_close_focus,
                     beautiful.titlebar_close_normal, function() c:kill() end)
               }
            }
         }
      }
   })

   local bottom = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1
   })

   awful.titlebar(c, { position = 'top',    size = dpi(32) }).widget = top
   awful.titlebar(c, { position = 'bottom', size = dpi(4) }).widget  = bottom
end
