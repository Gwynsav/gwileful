local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local weather = require('signal.system.weather')
local helpers = require('helpers')
local color = require(beautiful.colorscheme)
local icons = require('theme.icons')

return function()
   -- Current weather widgets!
   local _C = {}
   _C.icon = helpers.ctext({
      text  = icons.weather['day_clear'],
      font  = icons.font .. icons.size * 12,
      color = color.bg3
   })
   _C.desc = helpers.ctext({
      text = 'No weather info',
      font = beautiful.font_bitm .. beautiful.bitm_size * 2
   })
   _C.humy = helpers.ctext({
      text  = 'Humidity: N/A',
      color = color.fg2
   })
   _C.temp = helpers.ctext({
      text  = 'N/A',
      align = 'right',
      font  = beautiful.font_bitm .. beautiful.bitm_size * 2
   })
   _C.feel = helpers.ctext({
      text  = 'N/A',
      align = 'right',
      color = color.fg2
   })

   -- Hourly weather widgets!
   local _H = {}
   local hour_widgets = wibox.widget({
      layout  = wibox.layout.flex.horizontal,
      spacing = dpi(8)
   })

   local function hourly(index)
      local time = helpers.ctext({
         text  = '+' .. string.format('%02d', index) .. ':00',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center',
         color = color.fg1
      })
      local icon = helpers.ctext({
         text  = icons.weather['day_clear'],
         font  = icons.font .. icons.size * 2,
         align = 'center'
      })
      local temp = helpers.ctext({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center'
      })
      local humy = helpers.ctext({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center',
         color = color.fg2
      })

      return wibox.widget({
         layout = wibox.layout.fixed.vertical,
         time, icon, temp, humy,
         set_time = function(_, t)
            if t + index >= 24 then
               t = t + index - 24
            else
               t = t + index
            end
            time.text = string.format('%02d', math.floor(t)) .. ':00'
         end,
         set_icon = function(_, i)
            icon.text = i
         end,
         set_temp = function(_, t)
            temp.text = t .. '°C'
         end,
         set_humy = function(_, h)
            humy.text = h .. '%'
         end
      })
   end

   for i = 1, 6, 1 do
      local widget = hourly(i)
      table.insert(_H, widget)
      hour_widgets:add(widget)
   end

   -- Daily weather widgets!
   local _D = {}
   local day_widgets = wibox.widget({
      layout  = wibox.layout.flex.horizontal,
      visible = false,
      spacing = dpi(14)
   })
   local weekdays = { 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat' }

   local function daily(index)
      local time = helpers.ctext({
         text  = '+' .. index,
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center',
         color = color.fg1
      })
      local icon = helpers.ctext({
         text  = icons.weather['day_clear'],
         font  = icons.font .. icons.size * 2,
         align = 'center'
      })
      local max = helpers.ctext({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center'
      })
      local min = helpers.ctext({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center',
         color = color.fg2
      })

      return wibox.widget({
         layout = wibox.layout.fixed.vertical,
         time, icon, max, min,
         set_time = function(_, d)
            d = d + index
            if d > 7 then
               d = d - 7
            end
            time.text = weekdays[d]
         end,
         set_icon = function(_, i)
            icon.text = i
         end,
         set_max = function(_, t)
            max.text = t
         end,
         set_min = function(_, t)
            min.text = t
         end
      })
   end

   for i = 1, 6, 1 do
      local widget = daily(i)
      table.insert(_D, widget)
      day_widgets:add(widget)
   end

   -- Switch between hourly and daily forecast.
   local hour_toggle = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg2,
      {
         widget = wibox.container.margin,
         margins = {
            top = dpi(4), bottom = dpi(4),
            left = dpi(8), right = dpi(8)
         },
         {
            widget = helpers.ctext({
               text  = 'By Hour',
               align = 'center'
            }),
            id = 'text'
         }
      },
      set_col = function(self, col)
         self:get_children_by_id('text')[1].color = col
      end
   })
   local day_toggle = wibox.widget({
      widget = wibox.container.background,
      {
         widget = wibox.container.margin,
         margins = {
            top = dpi(4), bottom = dpi(4),
            left = dpi(8), right = dpi(8)
         },
         {
            widget = helpers.ctext({
               text  = 'By Day',
               align = 'center',
               color = color.fg2
            }),
            id = 'text'
         }
      },
      set_col = function(self, col)
         self:get_children_by_id('text')[1].color = col
      end
   })
   local toggle = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      border_width = dpi(1),
      border_color = color.bg3,
      {
         layout = wibox.layout.fixed.horizontal,
         {
            widget = hour_toggle,
            buttons = {
               awful.button(nil, 1, function()
                  hour_widgets.visible = true
                  day_widgets.visible  = false
                  hour_toggle.bg = color.bg2
                  hour_toggle.col = color.fg0
                  day_toggle.bg = color.bg2 .. '80'
                  day_toggle.col = color.fg2
               end)
            }
         },
         {
            widget = wibox.container.background,
            bg = color.bg3,
            forced_width = dpi(1)
         },
         {
            widget = day_toggle,
            buttons = {
               awful.button(nil, 1, function()
                  day_widgets.visible = true
                  hour_widgets.visible  = false
                  day_toggle.bg = color.bg2
                  day_toggle.col = color.fg0
                  hour_toggle.bg = color.bg2 .. '80'
                  hour_toggle.col = color.fg2
               end)
            }
         }
      }
   })

   local widget = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      border_width = dpi(1),
      border_color = color.bg3,
      visible = false,
      {
         widget  = wibox.container.margin,
         margins = dpi(16),
         {
            widget = wibox.layout.stack,
            _C.icon,
            {
               layout  = wibox.layout.fixed.vertical,
               spacing = dpi(12),
               {
                  layout = wibox.layout.align.horizontal,
                  {
                     layout = wibox.layout.fixed.vertical,
                     _C.desc,
                     _C.humy
                  },
                  nil,
                  {
                     layout = wibox.layout.fixed.vertical,
                     _C.temp,
                     _C.feel
                  }
               },
               {
                  layout = wibox.layout.align.horizontal,
                  expand = 'none',
                  nil, nil, toggle
               },
               {
                  layout = wibox.layout.align.horizontal,
                  expand = 'none',
                  nil,
                  {
                     layout = wibox.layout.stack,
                     hour_widgets,
                     day_widgets
                  },
                  nil
               }
            }
         }
      }
   })

   -- Global signals won't cut it, they get emitted before this widget is even drawn.
   weather:connect_signal('weather::data', function(_, info)
      widget.visible = true

      -- Current.
      _C.desc.text = info.description
      _C.humy.text = 'Humidity: ' .. info.humidity .. '%'
      _C.temp.text = info.temperature .. '°C'
      _C.feel.text = info.feels_like .. '°C'
      _C.icon.text = icons.weather[info.icon]

      -- Hourly.
      for i, w in ipairs(_H) do
         w.time = os.date('%H')
         w.icon = icons.weather[info.by_hour[i].icon]
         w.temp = info.by_hour[i].temp
         w.humy = info.by_hour[i].humidity
      end

      -- Daily.
      for i, w in ipairs(_D) do
         w.time = os.date('%w') + 1
         w.icon = icons.weather[info.by_day[i].icon]
         w.max  = info.by_day[i].max .. '°C'
         w.min  = info.by_day[i].min .. '°C'
      end
   end)

   -- Since the panel isn't drawn from the get-go, it may fail to catch the first emision
   -- of the `weather::data` signal. I opted to make the widget request a new emision
   -- when drawn for the first time.
   weather:request_data()

   return widget
end
