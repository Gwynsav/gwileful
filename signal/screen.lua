local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local widgets   = require('ui')
local user      = require('config.user')
local color     = require(beautiful.colorscheme)
local helpers   = require('helpers')

--- Attach tags and widgets to all screens.
screen.connect_signal('request::desktop_decoration', function(s)
   -- Create all tags and attach the layouts to each of them.
   local tags = {}
   for i = 1, user.tags - 1, 1 do
      table.insert(tags, i)
   end
   awful.tag(tags, s, awful.layout.layouts[1])
   awful.tag.add(user.tags, { screen = s, layout = awful.layout.suit.floating })

   -- Add padding to the screens themselves.
   s.padding = dpi(user.tag_padding)

   -- Attach some widgets to each screen.
   s.bar      = widgets.wibar(s)
   s.dash     = require('ui.dash')
   s.launcher = require('ui.launcher')
end)

-- Maybe something in the future.
-- local wall_widget = wibox.widget({
-- })

--- Wallpaper.
-- NOTE: `awful.wallpaper` is ideal for creating a wallpaper IF YOU
-- BENEFIT FROM IT BEING A WIDGET and not just the root window 
-- background. IF YOU JUST WISH TO SET THE ROOT WINDOW BACKGROUND, you 
-- may want to use the deprecated `gears.wallpaper` instead. This is 
-- the most common case of just wanting to set an image as wallpaper.
screen.connect_signal('request::wallpaper', function(s)
   awful.wallpaper({
      screen = s,
      widget = {
         -- layout = wibox.layout.stack,
         -- {
            widget = wibox.container.tile,
            valign = 'center',
            halign = 'center',
            tiled  = false,
            {
               widget    = wibox.widget.imagebox,
               image     = beautiful.wallpaper,
               upscale   = true,
               downscale = true
            }
         -- },
         -- {
         --    widget  = wibox.container.margin,
         --    margins = user.tag_padding + user.gaps * 2,
         --    wall_widget
         -- }
      }
   })
end)
-- An example of what's mentioned above. For more information, see:
-- https://awesomewm.org/apidoc/utility_libraries/gears.wallpaper.html
-- require('gears').wallpaper.maximized(user.wallpaper or beautiful.wallpaper)
