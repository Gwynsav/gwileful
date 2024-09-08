local require = require

local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color  = require(beautiful.colorscheme)
local module = require(... .. '.module')

return function(s)
   -- Left widgets.
   local left = wibox.widget({
      layout = wibox.layout.fixed.horizontal,
      {
         widget  = wibox.container.margin,
         margins = {
            top = dpi(6), bottom = dpi(6),
            right = dpi(16)
         },
         {
            layout  = wibox.layout.fixed.horizontal,
            spacing = dpi(12),
            {
               layout = wibox.layout.fixed.horizontal,
               module.layoutbox(s),
               module.taglist(s)
            },
            module.launcher(s)
         }
      },
      {
         widget = wibox.container.background,
         bg     = color.bg3,
         forced_width = dpi(1)
      }
   })

   -- Middle widgets.
   local center = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1 .. '80',
      module.tasklist(s)
   })

   -- Right widgets.
   local right = wibox.widget({
      layout = wibox.layout.fixed.horizontal,
      {
         widget = wibox.container.background,
         bg     = color.bg3,
         forced_width = dpi(1)
      },
      {
         widget  = wibox.container.margin,
         margins = { left = dpi(12) },
         {
            layout  = wibox.layout.fixed.horizontal,
            spacing = dpi(12),
            {
               widget  = wibox.container.margin,
               margins = {
                  top = dpi(6), bottom = dpi(6)
               },
               module.systray()
            },
            awful.widget.keyboardlayout(),
            {
               widget = wibox.container.margin,
               margins = {
                  top = dpi(6), bottom = dpi(6)
               },
               {
                  layout  = wibox.layout.fixed.horizontal,
                  spacing = dpi(12),
                  module.status(),
                  module.clock(s),
                  module.dash(s)
               }
            }
         }
      }
   })

   -- Create the wibox
   return awful.wibar({
      position = 'top',
      height   = dpi(36),
      screen   = s,
      widget   = {
         widget = wibox.container.background,
         bg     = color.bg3,
         {
            widget = wibox.container.margin,
            margins = { bottom = dpi(1) },
            {
               widget = wibox.container.background,
               bg     = color.bg0,
               {
                  widget  = wibox.container.margin,
                  margins = { left = dpi(16), right = dpi(16) },
                  {
                     layout = wibox.layout.align.horizontal,
                     expand = 'outer',
                     left,
                     center,
                     right
                  }
               }
            }
         }
      }
   })
end
