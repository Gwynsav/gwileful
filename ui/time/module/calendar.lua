-- Based off rxyhn's Yoru calendar.
-- https://github.com/rxyhn/yoru/blob/main/config/awesome/ui/panels/info-panel/calendar.lua

local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')
local gears     = require('gears')

local dpi = beautiful.xresources.apply_dpi

local hp    = require('helpers')
local color = require(beautiful.colorscheme)
local icons = require('theme.icons')

local function weekday_widget(name)
   return wibox.widget({
      widget = wibox.container.background,
      fg     = color.fg2,
      {
         widget  = wibox.container.margin,
         margins = { left = dpi(8) },
         wibox.widget.textbox(name)
      }
   })
end

local function day_widget(date, is_current, other_month)
   local col = color.fg0
   if is_current then
      col = color.bg0
   elseif other_month then
      col = color.bg4
   end

   return wibox.widget({
      widget = wibox.container.background,
      bg     = is_current and color.accent or color.transparent,
      fg     = col,
      {
         widget  = wibox.container.margin,
         margins = {
            left = dpi(6), right = dpi(6),
            top = dpi(8), bottom = dpi(8)
         },
         {
            widget = wibox.widget.textbox,
            halign = 'center',
            text   = date
         }
      }
   })
end

local calendar = { mt = {} }

function calendar:set_date(date)
   self.date = date
   self.days:reset()
   self.days:add(weekday_widget('Su'))
   self.days:add(weekday_widget('Mo'))
   self.days:add(weekday_widget('Tu'))
   self.days:add(weekday_widget('We'))
   self.days:add(weekday_widget('Th'))
   self.days:add(weekday_widget('Fr'))
   self.days:add(weekday_widget('Sa'))

   local current_date = os.date('*t')

   local first_day = os.date('*t', os.time({ year = date.year, month = date.month, day = 1}))
   local last_day  = os.date('*t', os.time({ year = date.year, month = date.month + 1, day = 0}))
   local month_days = last_day.day

   self.month:set_text(os.date('%B %Y', os.time({ year = date.year, month = date.month, day = 1 })))

   local days_to_add_at_month_start = first_day.wday - 1
	local days_to_add_at_month_end = 42 - last_day.day - days_to_add_at_month_start

	local previous_month_last_day = os.date("*t", os.time({ year = date.year, month = date.month, day = 0 })).day
	for day = previous_month_last_day - days_to_add_at_month_start, previous_month_last_day - 1, 1 do
		self.days:add(day_widget(day, false, true))
	end

	for day = 1, month_days do
		local is_current = day == current_date.day and date.month == current_date.month
		self.days:add(day_widget(day, is_current, false))
	end

	for day = 1, days_to_add_at_month_end do
		self.days:add(day_widget(day, false, true))
	end
end

function calendar:update_date()
	self:set_date(os.date("*t"))
end

function calendar:increase_date()
	local new_calendar_month = self.date.month + 1
	self:set_date({ year = self.date.year, month = new_calendar_month, day = self.date.day })
end

function calendar:decrease_date()
	local new_calendar_month = self.date.month - 1
	self:set_date({ year = self.date.year, month = new_calendar_month, day = self.date.day })
end

-- So here's where things actually go down
local function new()
   local ret = gears.object({})
   gears.table.crush(ret, calendar, true)

   ret.month = wibox.widget({
      widget = wibox.widget.textbox,
      text   = os.date('%B %Y'),
      buttons = {
         awful.button(nil, 1, function() ret:update_date() end)
      }
   })

   local function button(icon, action)
      local icon_widget = hp.ctext({
         text = icon,
         font = icons.font .. icons.size
      })

      local widget = wibox.widget({
         widget = wibox.container.background,
         bg     = color.bg0 .. '60',
         {
            widget = wibox.container.margin,
            margins = {
               left = dpi(8), right = dpi(8),
               top = dpi(6), bottom = dpi(6)
            },
            icon_widget
         },
         buttons = { awful.button(nil, 1, action) },
         set_image = function(_, image)
            icon_widget.text = image
         end,
         set_icon_color = function(_, fg)
            icon_widget.color = fg
         end
      })
      widget:connect_signal('mouse::enter', function(self)
         self.bg = color.accent
         self.icon_color = color.bg0
      end)
      widget:connect_signal('mouse::leave', function(self)
         self.bg = color.bg0 .. '60'
         self.icon_color = color.fg0
      end)
      return widget
   end

   local month = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      {
         layout = wibox.layout.align.horizontal,
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(6), bottom = dpi(6),
               left = dpi(10), right = dpi(10)
            },
            ret.month
         },
         nil,
         {
            layout = wibox.layout.fixed.horizontal,
            button(icons['arrow_left'], function() ret:decrease_date() end),
            button(icons['arrow_right'], function() ret:increase_date() end)
         }
      }
   })

   ret.days = wibox.widget({
      layout = wibox.layout.grid,
      forced_num_rows = 6,
      forced_num_cols = 7,
      spacing = dpi(5),
      expand = true
   })

   local widget = wibox.widget({
      layout  = wibox.layout.fixed.vertical,
      spacing = dpi(8),
      ret.days,
      month
   })

   ret:set_date(os.date('*t'))
   gears.table.crush(widget, calendar, true)
   return widget
end

function calendar.mt:__call()
	return new()
end

return setmetatable(calendar, calendar.mt)
