local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local helpers = require('helpers')
local color = require(beautiful.colorscheme)

return function()
   local hour = wibox.widget({
      widget  = wibox.widget.textclock,
      format  = '%H:%M:%S',
      refresh = 1,
      font    = beautiful.font_bitm .. dpi(18),
      halign  = 'center'
   })

   local date = wibox.widget({
      widget = wibox.widget.textbox,
      halign  = 'center'
   })
   require('gears').timer({
      timeout   = 60,
      call_now  = true,
      autostart = true,
      callback  = function()
         local day = tonumber(os.date('%e'))
         date.markup =
            os.date('%A, the ') .. day .. helpers.get_suffix(day) .. os.date(' of %B')
      end
   })

   return wibox.widget({
      layout = wibox.layout.fixed.vertical,
      hour,
      {
         widget = wibox.container.background,
         fg     = color.fg2,
         date
      }
   })
end
