local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local weather = require('signal.system.weather')
local helpers = require('helpers')
local color = require(beautiful.colorscheme)
local icons = require('theme.icons')

return function()
   local icon = helpers.ctext({
      text = icons.weather['day_clear'],
      font = icons.font .. icons.size
   })

   local widget = wibox.widget({
      layout  = wibox.layout.fixed.vertical,
      visible = false,
      spacing = dpi(16),
      {
         widget = wibox.container.background,
         bg     = color.bg3,
         forced_height = dpi(1)
      },
      {
         widget  = wibox.container.margin,
         margins = { left = dpi(8), right = dpi(8) },
         {
            layout = wibox.layout.align.horizontal,
            {
               layout = wibox.layout.fixed.horizontal,
               spacing = dpi(8),
               icon,
               {
                  widget = wibox.widget.textbox,
                  text = 'No weather info',
                  id = 'desc_role'
               }
            },
            nil,
            {
               widget = helpers.ctext({
                  text = 'N/A',
                  align = 'right'
               }),
               id = 'temp_role'
            }
         }
      },
      set_desc = function(self, text)
         self:get_children_by_id('desc_role')[1].text = text
      end,
      set_temp = function(self, text)
         self:get_children_by_id('temp_role')[1].text = text
      end
   })

   -- Global signals won't cut it, they get emitted before this widget is even drawn.
   weather:connect_signal('weather::data', function(_, info)
      widget.visible = true
      widget.desc = info.description
      widget.temp = info.temperature .. '°C (' .. info.feels_like ..  '°C)'
      icon.text = icons.weather[info.icon]
   end)

   -- Since the panel isn't drawn from the get-go, it may fail to catch the first emision
   -- of the `weather::data` signal. I opted to make the widget request a new emision
   -- when drawn for the first time.
   weather:request_data()

   return widget
end
