local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi
local color = require(beautiful.colorscheme)

local conf = require('config.user')

local pfp_widget = wibox.widget({
   widget = wibox.widget.imagebox,
   forced_height = dpi(45),
   forced_width  = dpi(45),
   image  = conf.pfp or beautiful.def_pfp
})

local user_at_host = wibox.widget({
   widget = wibox.container.background,
   bg     = color.fg0,
   fg     = color.bg0,
   {
      widget  = wibox.container.margin,
      margins = dpi(3),
      {
         layout = wibox.layout.fixed.horizontal,
         wibox.widget.textbox(os.getenv('USER') or 'user'),
         wibox.widget.textbox('@' .. (os.getenv('HOSTNAME') or 'host'))
      }
   }
})

-- Updated every minute.
local uptime_widget = wibox.widget({
   widget = wibox.widget.textbox,
   markup = '<i>Uptime unknown!</i>',
   forced_height = dpi(13), -- will expand beyond necessary height if not forced.
   set_txt = function(self, text)
      self.markup = '<i>' .. text .. '</i>'
   end
})

gears.timer({
   timeout   = 60,
   call_now  = true,
   autostart = true,
   callback  = function()
      awful.spawn.easy_async('uptime -p', function(up)
         uptime_widget.txt = up
      end)
   end
})

return function()
   return wibox.widget({
      layout = wibox.layout.fixed.vertical,
      {
         layout  = wibox.layout.align.horizontal,
         spacing = dpi(16),
         {
            widget = wibox.container.place,
            valign = 'center',
            {
               layout  = wibox.layout.fixed.vertical,
               spacing = dpi(2),
               -- Kind of annoying `wibox.container.background` quirk, to prevent it from
               -- stretching, you have to put it in some extra layout. I decided to kill
               -- two birds with one stone here and align the text using the layout itself.
               {
                  layout = wibox.layout.align.horizontal,
                  user_at_host,
                  nil, nil
               },
               uptime_widget
            }
         },
         nil,
         pfp_widget
      },
      {
         widget  = wibox.container.margin,
         margins = { bottom = dpi(16) }
      }
   })
end
