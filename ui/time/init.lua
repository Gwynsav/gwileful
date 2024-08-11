local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local mods  = require('ui.time.module')

local width, height, margin = dpi(260), dpi(370), dpi(6)

return function(s)
   local panel = wibox({
      ontop    = true,
      visible  = false,
      width    = width,
      height   = height,
      x        = margin,
      y        = margin + s.bar.height,
      bg       = color.bg0,
      border_width = dpi(1),
      border_color = color.bg3,
      widget = {
         widget  = wibox.container.margin,
         margins = dpi(16),
         {
            layout = wibox.layout.fixed.vertical,
            spacing = dpi(16),
            mods.clock(),
            mods.weather(),
            {
               widget = wibox.container.background,
               bg = color.bg3,
               forced_height = dpi(1)
            },
            mods.calendar()
         }
      }
   })

   function panel:show()
      self.visible = not self.visible
   end

   local grown = false
   require('signal.system.weather'):connect_signal('weather::data', function()
      if not grown then
         panel:geometry({
            x = panel.x, y = panel.y, width = panel.width,
            height = panel.height + dpi(45)
         })
         grown = true
      end
   end)

   return panel
end
