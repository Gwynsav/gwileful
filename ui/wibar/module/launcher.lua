local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local helpers = require('helpers')
local color = require(beautiful.colorscheme)

return function(s)
   local widget = wibox.widget({
      layout  = wibox.layout.fixed.horizontal,
      spacing = dpi(6),
      {
         widget = wibox.widget.imagebox,
         image  = beautiful.search,
         valign = 'center',
         id     = 'image_role',
         scaling_quality = 'nearest',
         forced_height   = dpi(9),
         forced_width    = dpi(9)
      },
      {
         widget = helpers.ctext('Search', beautiful.font_bitm .. dpi(9), color.fg0),
         id     = 'text_role'
      },
      buttons = {
         awful.button(nil, 1, function() s.launcher:open() end)
      },
      set_fg = function(self, col, icon)
         self:get_children_by_id('text_role')[1].fg = col
         self:get_children_by_id('image_role')[1].image = icon
      end
   })
   widget:connect_signal('mouse::enter', function(self)
      self.set_fg(self, color.accent, beautiful.search_hl)
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.set_fg(self, color.fg0, beautiful.search)
   end)

   return widget
end
