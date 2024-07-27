local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi
local color = require(beautiful.colorscheme)

local hp   = require('helpers')
local conf = require('config.user')

local pfp_widget = wibox.widget({
   widget = wibox.widget.imagebox,
   image  = gears.surface.crop_surface({
      surface = gears.surface.load_uncached(conf.pfp or beautiful.def_pfp),
      ratio   = 7/3,
      left    = dpi(48)
   })
})

local user_at_host = wibox.widget({
   layout = wibox.layout.fixed.horizontal,
   hp.ctext(os.getenv('USER') or 'user', beautiful.font_bitm .. dpi(18), color.accent),
   hp.ctext('@' .. (os.getenv('HOSTNAME') or 'host'), beautiful.font_bitm .. dpi(18), color.fg0)
})

-- Updated every minute.
local uptime_widget = hp.ctext('Uptime Unknown!', beautiful.font_bitm .. dpi(9), color.fg1)
gears.timer({
   timeout   = 60,
   call_now  = true,
   autostart = true,
   callback  = function()
      awful.spawn.easy_async('uptime -p', function(up)
         uptime_widget.text = up:gsub('\n', '')
      end)
   end
})

local function button(icon, icon_hl, action)
   local widget = wibox.widget({
      widget = wibox.widget.imagebox,
      image  = icon,
      halign = 'center',
      valign = 'center',
      forced_height = dpi(18),
      forced_width  = dpi(18),
      scaling_quality = 'nearest',
      buttons = { awful.button(nil, 1, action) }
   })
   widget:connect_signal('mouse::enter', function(self)
      self.image = icon_hl
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.image = icon
   end)
   return widget
end

return function()
   return wibox.widget({
      layout = wibox.layout.stack,
      {
         layout = wibox.layout.fixed.horizontal,
         {
            widget   = wibox.container.constraint,
            strategy = 'exact',
            width    = dpi(240),
            {
               layout = wibox.layout.stack,
               pfp_widget,
               {
                  widget = wibox.container.background,
                  bg     = {
                     type  = 'linear',
                     from  = { dpi(240), 0 },
                     to    = { 0, 0 },
                     stops = {
                        { 0, color.bg1 }, { 0.33, color.bg1 .. 'F0' },
                        { 0.66, color.bg1 .. 'DC' }, { 1, color.bg1 .. 'C0' }
                     }
                  }
               }
            }
         },
         {
            widget = wibox.container.background,
            bg     = color.bg1,
            forced_width = dpi(115)
         }
      },
      {
         widget  = wibox.container.margin,
         margins = dpi(16),
         {
            layout = wibox.layout.align.vertical,
            {
               layout  = wibox.layout.fixed.vertical,
               spacing = dpi(2),
               -- Text alignment sucks.
               {
                  layout = wibox.layout.align.horizontal,
                  nil, nil, user_at_host
               },
               {
                  layout = wibox.layout.align.horizontal,
                  nil, nil, uptime_widget

               }
            },
            nil,
            {
               layout  = wibox.layout.fixed.horizontal,
               spacing = dpi(8),
               button(beautiful.shutdown, beautiful.shutdown_hl,
                        function() awful.spawn(conf.shutdown_cmd) end),
               button(beautiful.reboot, beautiful.reboot_hl,
                        function() awful.spawn(conf.reboot_cmd) end),
               button(beautiful.suspend, beautiful.suspend_hl,
                        function() awful.spawn(conf.suspend_cmd) end),
               button(beautiful.logoff, beautiful.logoff_hl,
                        function() awesome.quit() end)
            }
         }
      }
   })
end
