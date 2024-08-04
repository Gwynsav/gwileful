local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local _H = {}

-- Makes a colored textbox.
-- @param args:
--    - text: the text to be displayed.
--    - font: the font to be used.
--    - color: the text color.
--    - align: whether to align text to 'left', 'center' or 'right'.
function _H.ctext(args)
   local conf = gears.table.crush({
      text  = '',
      font  = beautiful.font,
      color = beautiful.fg_normal,
      align = 'left'
   }, args, true)

   return wibox.widget({
      widget = wibox.container.background,
      fg     = conf.color,
      {
         widget = wibox.widget.textbox,
         markup = conf.text,
         font   = conf.font,
         halign = conf.align,
         id     = 'text_role'
      },
      set_text = function(self, new_text)
         self:get_children_by_id('text_role')[1].markup = new_text
      end,
      set_color = function(self, new_color)
         self.fg = new_color
      end
   })
end

-- Makes a scrolling text container. Takes the same args table as `ctext`,
-- plus `dir`, the direction in which the widget will scroll.
function _H.stext(args)
   local conf = gears.table.crush({
      text  = '',
      font  = beautiful.font,
      color = beautiful.fg_normal,
      align = 'left',
      dir   = 'horizontal'
   }, args, true)

   local scroll
   if conf.dir == 'horizontal' then
      scroll = wibox.container.scroll.horizontal
   else
      scroll = wibox.container.scroll.vertical
   end

   return wibox.widget({
      widget = scroll,
      step_function =
         wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
      speed = 50,
      {
         widget = _H.ctext({
            text  = conf.text,
            font  = conf.font,
            color = conf.color,
            align = conf.align
         }),
         id = 'text_role'
      },
      set_text = function(self, new_text)
         self:get_children_by_id('text_role')[1].text = new_text
      end,
      set_color = function(self, new_color)
         self:get_children_by_id('text_role')[1].fg = new_color
      end
   })
end

-- I feel like YanDev saying "I wish there was a better way to do this"...
-- Gets the suffix for any given day of the month.
function _H.get_suffix(day)
   if day > 3 and day < 21 then
      return 'th'
   end

   if day % 10 == 1 then
      return 'st'
   elseif day % 10 == 2 then
      return 'nd'
   elseif day % 10 == 3 then
      return 'rd'
   else
      return 'th'
   end
end

function _H.in_table(ele, table)
   for _, v in table do
      if v == ele then
         return true
      end
   end
   return false
end

return _H
