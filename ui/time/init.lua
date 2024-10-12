local require = require

local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local mods  = require('ui.time.module')

local width, height, margin = dpi(300), dpi(370), dpi(6)

return function(s)
   local panel = wibox({
      ontop    = true,
      visible  = false,
      width    = width,
      height   = height,
      x        = s.geometry.width - (margin + width),
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
            {
               widget = wibox.container.background,
               bg = color.bg3,
               forced_height = dpi(1)
            },
            {
               widget = wibox.container.constraint,
               strategy = 'exact',
               height = dpi(270),
               mods.calendar.main_widget
            },
            mods.weather()
         }
      }
   })

   function panel:hide()
      self.visible = false
   end

   function panel:show()
      s.dash:hide()
      self.visible = true
   end

   function panel:toggle()
      if self.visible then
         self:hide()
      else
         self:show()
      end
   end

   local grown = false
   require('signal.system.weather'):connect_signal('weather::data', function()
      if not grown then
         panel:geometry({
            x = panel.x, y = panel.y, width = panel.width,
            height = panel.height + dpi(200)
         })
         grown = true
      end
   end)

   return panel
end
