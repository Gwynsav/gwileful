--- A scrolling, colorable textbox widget.

local require, type, setmetatable = require, type, setmetatable

local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local textbox = { mt = {} }

--- Create a scrolling, colorable textbox widget. Like a regular `wibox.widget.textbox`,
--- but also capable of coloring its text, and scrolling in either axis.
-- @constructorfct widget.textbox.scrolling
-- @tparam string The text to be displayed.
-- @tparam table args The arguments.
-- @tparam string args.text The text to be displayed.
-- @tparam string args.font The font to be used.
-- @tparam string args.color The color the text will be by default.
-- @tparam string args.align The horizontal text alignment (left, center, right).
-- @tparam string args.dir The axis on which to scroll (horizontal, vertical).
-- @return The scrollable, colored textbox.
function textbox.new(args)
   -- Make sure the args have the correct type.
   local args_type = type(args)
   if args_type == 'string' or args_type == 'number' then
      local text = args
      args = {}
      args.text = text
   end
   assert(type(args) == 'table')

   -- Normalize args.
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

   local w = wibox.widget({
      widget = scroll,
      step_function =
         wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
      speed = 50,
      {
         widget = require('widget.textbox.colored')({
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

   return w
end

function textbox.mt:__call(...)
   return textbox.new(...)
end

return setmetatable(textbox, textbox.mt)

