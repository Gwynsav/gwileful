local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi
local color = require(beautiful.colorscheme)
local icons = require('theme.icons')

local hp   = require('helpers')
local conf = require('config.user')

local pfp_widget = wibox.widget({
   widget = wibox.widget.imagebox,
   image  = gears.surface.crop_surface({
      surface = beautiful.pfp,
      ratio   = 7/3,
      left    = dpi(48)
   })
})

local host = hp.ctext({
   text  = '@host',
   font  = beautiful.font_bitm .. beautiful.bitm_size * 2,
   align = 'right'
})
local user_at_host = wibox.widget({
   layout = wibox.layout.fixed.horizontal,
   hp.ctext({
      text  = os.getenv('USER') or 'user',
      font  = beautiful.font_bitm .. beautiful.bitm_size * 2,
      color = color.accent,
      align = 'right'
   }),
   host
})
awful.spawn.easy_async_with_shell('uname -n', function(out)
   if out == nil or out == '' then return end
   host.text = '@' .. out:gsub('\n', '')
end)

-- Updated every minute.
local uptime_widget = hp.ctext({
   text  = 'Uptime Unknown!',
   color = color.fg1,
   align = 'right'
})
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

local function button(icon, action)
   local widget = hp.ctext({
      font = icons.font .. icons.size * 2,
      text = icon
   })
   widget.buttons = { awful.button(nil, 1, action) }
   widget.set_action = function(self, new_action)
      self.buttons = { awful.button(nil, 1, new_action) }
   end
   widget:connect_signal('mouse::enter', function(self)
      self.color = color.red
   end)
   widget:connect_signal('mouse::leave', function(self)
      self.color = color.fg0
   end)
   return widget
end

-- Power options revealer.
local show_power = button(icons['arrow_right'], function() end)
local power = wibox.widget({
   layout = wibox.layout.fixed.horizontal,
   spacing = dpi(8),
   show_power,
   {
      layout  = wibox.layout.fixed.horizontal,
      spacing = dpi(8),
      visible = false,
      id      = 'power',
      button(icons['power_shutdown'], function() awful.spawn(conf.shutdown_cmd) end),
      button(icons['power_reboot'],   function() awful.spawn(conf.reboot_cmd) end),
      button(icons['power_suspend'],  function() awful.spawn(conf.suspend_cmd) end),
      button(icons['power_logoff'],   function() awesome.quit() end)
   },
   toggle_show_power = function(self)
      local power = self:get_children_by_id('power')[1]
      power.visible = not power.visible
      show_power.text = power.visible and icons['arrow_left'] or icons['arrow_right']
   end
})
show_power.action = function()
   power.toggle_show_power(power)
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
                  nil, nil,
                  user_at_host,
               },
               uptime_widget
            },
            nil,
            power
         }
      }
   })
end
