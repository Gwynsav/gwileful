local require, string, os, table, ipairs = require, string, os, table, ipairs

local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local imperial = require('config.user').imperial
local weather = require('signal.system.weather')
local widget  = require('widget')
local color   = require(beautiful.colorscheme)
local icons   = require('theme.icons')

return function()
   -- Current weather widgets!
   local _C = {}
   _C.icon = widget.textbox.colored({
      text  = icons.weather['day_clear'],
      font  = icons.font .. icons.size * 12,
      color = color.bg3 .. 'A0'
   })
   _C.desc = widget.textbox.colored({
      text = 'No weather info',
      font = beautiful.font_bitm .. beautiful.bitm_size * 2
   })
   _C.humy = widget.textbox.colored({
      text  = 'Humidity: N/A',
      color = color.fg2
   })
   _C.temp = widget.textbox.colored({
      text  = 'N/A',
      align = 'right',
      font  = beautiful.font_bitm .. beautiful.bitm_size * 2
   })
   _C.feel = widget.textbox.colored({
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
      local time = widget.textbox.colored({
         text  = '+' .. string.format('%02d', index) .. ':00',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center',
         color = color.fg1
      })
      local icon = widget.textbox.colored({
         text  = icons.weather['day_clear'],
         font  = icons.font .. icons.size * 2,
         align = 'center'
      })
      local temp = widget.textbox.colored({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center'
      })
      local rain = widget.textbox.colored({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         align = 'center',
         color = color.fg2
      })

      return wibox.widget({
         layout = wibox.layout.fixed.vertical,
         time, icon, temp, rain,
         set_time = function(_, t)
            time.text = t
         end,
         set_icon = function(_, i)
            icon.text = i
         end,
         set_temp = function(_, t)
            temp.text = t
         end,
         set_rain = function(_, h)
            rain.text = h
         end
      })
   end

   for i = 1, 6, 1 do
      local w = hourly(i)
      table.insert(_H, w)
      hour_widgets:add(w)
   end

   -- Daily weather widgets!
   local _D = {}
   local day_widgets = wibox.widget({
      layout  = wibox.layout.flex.horizontal,
      visible = false,
      spacing = dpi(16)
   })
   local weekdays = {
      'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'
   }

   local function daily(index)
      local time = widget.textbox.colored({
         text  = '+' .. index,
         font  = beautiful.font_mono .. beautiful.bitm_size,
         color = color.fg1
      })
      local icon = widget.textbox.colored({
         text  = icons.weather['day_clear'],
         font  = icons.font .. icons.size * 4
      })
      local max = widget.textbox.colored({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size
      })
      local rain = widget.textbox.colored({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size
      })
      local humy = widget.textbox.colored({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         color = color.fg2
      })
      local min = widget.textbox.colored({
         text  = 'N/A',
         font  = beautiful.font_mono .. beautiful.bitm_size,
         color = color.fg2
      })

      return wibox.widget({
         widget  = wibox.container.margin,
         margins = { top = dpi(1), bottom = dpi(2) },
         {
            layout  = wibox.layout.fixed.horizontal,
            spacing = dpi(9),
            icon,
            {
               layout  = wibox.layout.fixed.vertical,
               spacing = dpi(2),
               time,
               {
                  layout  = wibox.layout.fixed.vertical,
                  {
                     layout = wibox.layout.fixed.horizontal,
                     widget.textbox.colored({
                        text  = 'T: ',
                        color = color.red
                     }), max, wibox.widget.textbox('/'), min,
                     wibox.widget.textbox(imperial and '°F' or '°C')
                  },
                  {
                     layout = wibox.layout.fixed.horizontal,
                     widget.textbox.colored({
                        text  = 'H: ',
                        color = color.yellow
                     }), humy
                  },
                  {
                     layout = wibox.layout.fixed.horizontal,
                     widget.textbox.colored({
                        text  = 'R: ',
                        color = color.blue
                     }), rain
                  }
               }
            }
         },
         set_time = function(_, d)
            d = d + index + 1
            if d > 7 then
               d = d - 7
            end
            time.text = weekdays[d]
         end,
         set_icon = function(_, i)
            icon.text = i
         end,
         set_max = function(_, t)
            max.text = t:gsub('°[C,F]', '')
         end,
         set_min = function(_, t)
            min.text = t:gsub('°[C,F]', '')
         end,
         set_rain = function(_, r)
            rain.text = r
         end,
         set_humy = function(_, r)
            humy.text = r
         end
      })
   end

   for i = 1, 2, 1 do
      local w = daily(i)
      table.insert(_D, w)
      day_widgets:add(w)
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
            widget = widget.textbox.colored({
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
            widget = widget.textbox.colored({
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

   local w = wibox.widget({
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
               widget = wibox.container.background,
               bg = {
                  type = 'linear',
                  from = { 0, 0, 0 },
                  to = { 0, 160, 0 },
                  stops = {
                     { 0, color.bg1 .. '00' }, { 0.7, color.bg1 }, { 1, color.bg1 }
                  }
               }
            },
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
      w.visible = true

      -- Current.
      _C.desc.text = info.description
      _C.humy.text = 'Humidity: ' .. info.humidity
      _C.temp.text = info.temperature
      _C.feel.text = info.feels_like
      _C.icon.text = icons.weather[info.icon]

      -- Hourly.
      -- Widget can only hold 6 at a time, make sure they're relevant!
      local off = 0
      if #info.by_hour > #_H then
         local curr_h = tonumber(os.date('%H'))
         for i = 1, #info.by_hour - #_H, 1 do
            if curr_h > (i * 24 / #info.by_hour) then
               off = off + 1
            end
         end
      end
      for i, h in ipairs(_H) do
         local hour = info.by_hour[i + off]
         h.time = hour.time
         h.icon = icons.weather[hour.icon]
         h.temp = hour.temperature
         h.rain = hour.rain_chance
      end

      -- Daily.
      for i, d in ipairs(_D) do
         d.time = tonumber(os.date('%w'))
         d.icon = icons.weather[info.by_day[i].icon]
         d.max  = info.by_day[i].max_temp
         d.min  = info.by_day[i].min_temp
         d.rain = info.by_day[i].rain_chance
         d.humy = info.by_day[i].humidity
      end
   end)

   -- Since the panel isn't drawn from the get-go, it may fail to catch the first emision
   -- of the `weather::data` signal. I opted to make the widget request a new emision
   -- when drawn for the first time.
   weather:request_data()

   return w
end
