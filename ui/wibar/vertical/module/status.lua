local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local icon  = gears.filesystem.get_configuration_dir() .. 'theme/assets/status/'

local kb_layout = wibox.widget({
   widget = wibox.container.background,
   bg     = color.transparent,
   {
      widget  = wibox.container.margin,
      margins = {
         top = dpi(6), bottom = dpi(3),
         left = dpi(6), right = dpi(6)
      },
      {
         layout = wibox.layout.stack,
         {
            widget     = wibox.widget.imagebox,
            stylesheet = string.format('*{ fill: %s; }', color.fg0),
            image      = icon .. 'keyboard.svg'
         },
         {
            widget  = wibox.container.margin,
            margins = { top = dpi(20) },
            {
               widget = wibox.container.place,
               halign = 'center',
               awful.widget.keyboardlayout()
            }
         }
      }
   }
})

return function()
   return wibox.widget({
      layout = wibox.layout.fixed.vertical,
      kb_layout
   })
end
