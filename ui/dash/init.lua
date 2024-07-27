local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local mods  = require('ui.dash.module')

local width, height, margin = 352, 500, 6
local screen = awful.screen.focused()

local panel = wibox({
   ontop    = true,
   visible  = false,
   width    = dpi(width),
   height   = dpi(height),
   bg       = color.bg0,
   x        = dpi(screen.geometry.width - width - margin),
   y        = dpi(margin + screen.bar.height),
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
               widget = wibox.widget.textbox,
               text   = 'Every ray of light is an invitation to death.',
               halign = 'center'
            }
         }
      },
      {
         widget  = wibox.container.margin,
         margins = {
            left = dpi(16), right = dpi(16),
            bottom = dpi(16)
         },
         mods.title()
      }
   }
})

function panel:show()
   self.visible = not self.visible
end

return panel
