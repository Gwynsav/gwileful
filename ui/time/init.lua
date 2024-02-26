local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local mods  = require('ui.time.module')

local width, height, margin = 260, 293, 6
local screen = awful.screen.focused()

local panel = wibox({
   ontop    = true,
   visible  = false,
   width    = dpi(width),
   height   = dpi(height),
   bg       = color.bg0,
   x        = dpi(screen.geometry.width - width - margin),
   y        = dpi(screen.geometry.height - height - margin - screen.bar.height),
   border_width = dpi(1),
   border_color = color.bg3,
   widget = {
      widget  = wibox.container.margin,
      margins = dpi(16),
      mods.calendar()
   }
})

function panel:show()
   self.visible = not self.visible
end

return panel
