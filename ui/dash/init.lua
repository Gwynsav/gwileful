local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local mods  = require('ui.dash.module')

local width, height, margin = 352, 510, 6

return function(s)
   local panel = wibox({
      ontop    = true,
      visible  = false,
      width    = dpi(width),
      height   = dpi(height),
      bg       = color.bg0,
      x        = dpi(s.geometry.width - width - margin),
      y        = dpi(margin + s.bar.height),
      border_width = dpi(1),
      border_color = color.bg3,
      widget = {
         layout = wibox.layout.align.vertical,
         {
            layout = wibox.layout.fixed.vertical,
            mods.user(),
            {
               widget = wibox.container.background,
               forced_height = dpi(1),
               bg = color.bg3
            }
         },
         {
            widget  = wibox.container.margin,
            margins = dpi(16),
            {
               layout  = wibox.layout.fixed.vertical,
               spacing = dpi(16),
               mods.grid(),
               {
                  widget = wibox.container.background,
                  bg     = color.bg3,
                  forced_height = dpi(1)
               },
               mods.player(),
               mods.slider(),
               {
                  widget = wibox.container.background,
                  bg     = color.bg3,
                  forced_height = dpi(1)
               },
               {
                  layout = wibox.layout.align.vertical,
                  expand = 'none',
                  nil, mods.random(), nil
               }
            }
         },
         mods.title()
      }
   })

   function panel:hide()
      self.visible = false
   end

   function panel:show()
      s.time:hide()
      self.visible = true
   end

   function panel:toggle()
      if self.visible then
         self:hide()
      else
         self:show()
      end
   end

   return panel
end
