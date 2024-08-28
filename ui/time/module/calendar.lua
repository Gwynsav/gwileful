-- From Myagko, see:
-- https://github.com/myagko/dotfiles/blob/0122545e8245d11852fb6785be8fc72c41928574/home/.config/awesome/ui/calendar.lua

local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)
local icons = require('theme.icons')

local calendar = {}
local instance = nil

local hebr_format = {
	[1] = 7,
	[2] = 1,
	[3] = 2,
	[4] = 3,
	[5] = 4,
	[6] = 5,
	[7] = 6
}

local wday_map = {
   ['Mon'] = 'Mo',
   ['Tue'] = 'Tu',
   ['Wed'] = 'We',
   ['Thu'] = 'Th',
   ['Fri'] = 'Fr',
   ['Sat'] = 'Sa',
   ['Sun'] = 'Su'
}

local function create_wday_widget(wday, col)
	local fg_color = col or color.fg0
	return wibox.widget {
		widget = wibox.container.background,
		fg = fg_color,
		{
			widget = wibox.container.margin,
			margins = dpi(10),
			{
				widget = wibox.widget.textbox,
				align = "center",
				text = wday
			}
		}
	}
end

local function create_day_widget(day, is_current, is_another_month)
	local fg_color = color.fg0
	local bg_color = color.bg1

	if is_current then
		fg_color = color.bg0
		bg_color = color.accent
	elseif is_another_month then
		fg_color = color.fg2
		bg_color = color.bg1 .. '80' -- TODO
	end

	return wibox.widget {
		widget = wibox.container.background,
		fg = fg_color,
		bg = bg_color,
		{
			widget = wibox.container.margin,
			margins = dpi(10),
			{
				widget = wibox.widget.textbox,
				halign = "center",
				valign = "center",
				text = day
			}
		}
	}
end

local function button(icon, action)
   local widget = wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg1,
      buttons = {
         awful.button({}, 1, action)
      },
      {
         widget  = wibox.container.margin,
         margins = {
            top = dpi(6), bottom = dpi(4),
            left = dpi(8), right = dpi(8)
         },
         {
            widget = wibox.widget.textbox,
            font = icons.font .. icons.size,
            text = icons[icon],
            halign = 'center',
            valign = 'center'
         }
      }
   })
   widget:connect_signal('mouse::enter', function(self)
      self.bg = color.bg2 .. '80'
      self.fg = color.accent
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.bg = color.bg1
      self.fg = color.fg0
   end)

   return widget
end

function calendar:set(date)
	calendar.day_layout:reset()
	self.date = date

	local curr_date = os.date("*t")
	local firstday = os.date("*t", os.time({ year = date.year, month = date.month, day = 1 }))
	local lastday = os.date("*t", os.time({ year = date.year, month = date.month + 1, day = 0 }))

	local month_count = lastday.day
	local month_start = not self.sun_start and hebr_format[firstday.wday] or firstday.wday
	local rows = math.max(5, math.min(6, 5 - (36 - (month_start + month_count))))

	local month_prev_lastday = os.date("*t", os.time({ year = date.year, month = date.month, day = 0 })).day
	local month_prev_count = month_start - 1
	local month_next_count = rows*7 - lastday.day - month_prev_count

	self.top_widget.title = os.date("%B %Y", os.time(date))

	for day = month_prev_lastday - (month_prev_count - 1), month_prev_lastday, 1 do
		self.day_layout:add(create_day_widget(day, false, true))
	end

	for day = 1, month_count, 1 do
		local is_current = day == curr_date.day and date.month == curr_date.month and date.year == curr_date.year
		self.day_layout:add(create_day_widget(day, is_current, false))
	end

	for day = 1, month_next_count, 1 do
		self.day_layout:add(create_day_widget(day, false, true))
	end
end

function calendar:inc(dir)
	local new_calendar_month = self.date.month + dir
	self:set({ year = self.date.year, month = new_calendar_month, day = self.date.day })
end

local function new()
	local ret = calendar


	ret.sun_start = false

	ret.day_layout = wibox.widget {
		layout = wibox.layout.grid,
		forced_num_cols = 7,
		expand = true,
		forced_height = dpi(230)
	}

	ret.wday_layout = wibox.widget {
		layout = wibox.layout.flex.horizontal
	}

	for i = 1, 7 do
		if ret.sun_start then
			i = i - 1
			if i > 0 and i < 6 then
				ret.wday_layout:add(create_wday_widget(wday_map[os.date("%a", os.time({year = 1, month = 1, day = i}))]))
			else
				ret.wday_layout:add(create_wday_widget(wday_map[os.date("%a", os.time({year = 1, month = 1, day = i}))], color.red))
			end
		else
			if i < 6 then
				ret.wday_layout:add(create_wday_widget(wday_map[os.date("%a", os.time({year = 1, month = 1, day = i}))]))
			else
				ret.wday_layout:add(create_wday_widget(wday_map[os.date("%a", os.time({year = 1, month = 1, day = i}))], color.red))
			end
		end
	end

   local title_text = wibox.widget({
      widget = wibox.widget.textbox,
      halign = "center",
      valign = "center"
   })
   local title = wibox.widget({
      widget = wibox.container.background,
      buttons = {
         awful.button({}, 1, function()
            ret:set(os.date("*t"))
         end)
      },
      title_text
   })
   title:connect_signal('mouse::enter', function(self)
      self.fg = color.accent
   end)
   title:connect_signal('mouse::leave', function(self)
      self.fg = color.fg0
   end)

	ret.top_widget = wibox.widget {
      widget = wibox.container.background,
      bg = color.bg1,
      {
         layout = wibox.layout.align.horizontal,
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(8), bottom = dpi(6),
               left = dpi(10), right = dpi(10)
            },
            title
         },
         nil,
         {
            widget = wibox.layout.fixed.horizontal,
            {
               widget = wibox.container.background,
               bg = color.bg3,
               forced_width = dpi(1)
            },
            button('arrow_left', function() ret:inc(-1) end),
            {
               widget = wibox.container.background,
               bg = color.bg3,
               forced_width = dpi(1)
            },
            button('arrow_right', function() ret:inc(1) end)
         }
      },
      set_title = function(_, text)
         title_text.text = text
      end
	}

	ret.main_widget = wibox.widget {
		widget = wibox.container.background,
		bg = color.bg0,
		border_width = dpi(1),
		border_color = color.bg3,
		{
         layout = wibox.layout.align.vertical,
         {
            layout = wibox.layout.fixed.vertical,
            ret.top_widget,
            {
               widget = wibox.container.background,
               bg     = color.bg3,
               forced_height = dpi(1)
            }
         },
         nil,
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(8), bottom = dpi(16),
               left = dpi(16), right = dpi(16)
            },
            {
               layout = wibox.layout.fixed.vertical,
               spacing = dpi(5),
               ret.wday_layout,
               ret.day_layout
            }
         }
		}
	}

   ret:set(os.date("*t"))

	return ret
end

if not instance then
	instance = new()
end

return instance
