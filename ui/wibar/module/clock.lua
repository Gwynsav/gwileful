local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local helpers = require('helpers')
local color = require(beautiful.colorscheme)

return function()
   -- A simple widget that shows the correct suffix for the current date.
   local day_suffix = wibox.widget({ widget = wibox.widget.textbox })
   require('gears').timer({
      timeout   = 60,
      call_now  = true,
      autostart = true,
      callback  = function()
         local day = tonumber(os.date('%d'))
         day_suffix.markup = os.date('%B ') .. day .. helpers.get_suffix(day)
      end
   })

   local clock = wibox.widget({
      widget = wibox.container.background,
      fg     = color.fg0,
      {
         layout  = wibox.layout.fixed.horizontal,
         spacing = dpi(12),
         day_suffix,
         {
            widget = wibox.widget.textclock,
            format = '<b>%H:%M</b>'
         }
      },
      buttons = {
         awful.button(nil, 1, function()
            require('ui.time'):show()
         end)
      }
   })
   clock:connect_signal('mouse::enter', function(self)
      self.fg = color.accent
   end)
   clock:connect_signal('mouse::leave', function(self)
      self.fg = color.fg0
   end)

   return clock
end
