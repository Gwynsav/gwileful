--- A colorable textbox widget.

local require, type, setmetatable = require, type, setmetatable

local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local textbox = { mt = {} }

--- Create a colorable textbox widget. Like a regular `wibox.widget.textbox`, but also
--- capable of coloring its text.
-- @constructorfct widget.textbox.colored
-- @tparam string The text to be displayed.
-- @tparam table args The arguments.
-- @tparam string args.text The text to be displayed.
-- @tparam string args.font The font to be used.
-- @tparam string args.color The color the text will be by default.
-- @tparam string args.align The horizontal text alignment (left, center, right).
-- @return The colored textbox.
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
      align = 'left'
   }, args, true)

   local w = wibox.widget({
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

   return w
end

function textbox.mt:__call(...)
   return textbox.new(...)
end

return setmetatable(textbox, textbox.mt)
