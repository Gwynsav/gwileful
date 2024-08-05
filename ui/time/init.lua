local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local mods  = require('ui.time.module')

local width, height, margin = 260, 370, 6
local screen = awful.screen.focused()

local panel = wibox({
   ontop    = true,
   visible  = false,
   width    = dpi(width),
   height   = dpi(height),
   bg       = color.bg0,
   x        = dpi(margin),
   y        = dpi(margin + screen.bar.height),
   border_width = dpi(1),
   border_color = color.bg3,
   widget = {
      widget  = wibox.container.margin,
      margins = dpi(16),
      {
         layout = wibox.layout.fixed.vertical,
         spacing = dpi(16),
         mods.clock(),
         {
            widget = wibox.container.background,
            bg = color.bg2,
            forced_height = dpi(1)
         },
         mods.calendar()
      }
   }
})

function panel:show()
   self.visible = not self.visible
end

return panel
