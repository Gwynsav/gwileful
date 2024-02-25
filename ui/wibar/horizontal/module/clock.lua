local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color = require(beautiful.colorscheme)

return function()
   -- I feel like YanDev saying "I wish there was a better way to do this"...
   local function get_suffix(day)
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

   -- A simple widget that shows the correct suffix for the current date.
   local day_suffix = wibox.widget({ widget = wibox.widget.textbox })
   require('gears').timer({
      timeout   = 60,
      call_now  = true,
      autostart = true,
      callback  = function()
         local day = tonumber(os.date('%d'))
         day_suffix.markup = '<i>' .. os.date('%B ') .. day .. get_suffix(day) .. '</i>'
      end
   })

   local clock = wibox.widget({
      widget = wibox.container.background,
      fg     = color.fg0,
      {
         layout  = wibox.layout.fixed.horizontal,
         spacing = dpi(10),
         {
            widget = wibox.widget.textclock,
            format = '%H:%M'
         },
         {
            widget = wibox.container.background,
            fg     = color.fg2 .. '7f',
            {
               widget = wibox.widget.textbox,
               text   = '|'
            }
         },
         day_suffix
      },
      buttons = {
         awful.button(nil, 1, function()
            require('ui.time'):show()
         end)
      }
   })
   clock:connect_signal('mouse::enter', function(self)
      self.fg = color.accent
   end)
   clock:connect_signal('mouse::leave', function(self)
      self.fg = color.fg0
   end)

   return clock
end
