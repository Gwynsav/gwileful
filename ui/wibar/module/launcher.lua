local require = require

local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local widget = require('widget')
local color  = require(beautiful.colorscheme)
local icons  = require('theme.icons')

return function(s)
   local w = wibox.widget({
      layout  = wibox.layout.fixed.horizontal,
      spacing = dpi(6),
      {
         widget = widget.textbox.colored({
            text = icons['util_magnifier'],
            font = icons.font .. icons.size
         }),
         id = 'icon_role'
      },
      {
         widget = widget.textbox.colored({ text = 'Search' }),
         id = 'text_role'
      },
      buttons = {
         awful.button(nil, 1, function() s.launcher:open() end)
      },
      set_fg = function(self, col)
         self:get_children_by_id('text_role')[1].color = col
         self:get_children_by_id('icon_role')[1].color = col
      end
   })
   w:connect_signal('mouse::enter', function(self)
      self.fg = color.accent
   end)
   w:connect_signal('mouse::leave', function(self)
      self.fg = color.fg0
   end)

   return w
end
