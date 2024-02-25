local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local mods  = require('ui.time.module')

local panel = wibox({
   ontop    = true,
   visible  = false,
   width    = dpi(300),
   height   = dpi(293),
   bg       = color.bg0,
   x        = dpi(1615),
   y        = dpi(745),
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
