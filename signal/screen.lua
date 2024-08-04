local awful     = require('awful')
local beautiful = require('beautiful')

local dpi = beautiful.xresources.apply_dpi

local widgets   = require('ui')
local user      = require('config.user')

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

   -- Attach a bar to each screen.
   s.bar = widgets.wibar(s)
end)

-- It doesn't make a whole lot of sense to have these in every screen.
local main_screen = awful.screen.focused()
main_screen.dash     = require('ui.dash')
main_screen.launcher = require('ui.launcher')
require('ui.osd')

--- Wallpaper.
-- NOTE: `awful.wallpaper` is ideal for creating a wallpaper IF YOU
-- BENEFIT FROM IT BEING A WIDGET and not just the root window 
-- background. IF YOU JUST WISH TO SET THE ROOT WINDOW BACKGROUND, you 
-- may want to use the deprecated `gears.wallpaper` instead. This is 
-- the most common case of just wanting to set an image as wallpaper.
-- screen.connect_signal('request::wallpaper', function(s)
--    awful.wallpaper({
--       screen = s,
--       widget = {
--          widget = wibox.container.tile,
--          valign = 'center',
--          halign = 'center',
--          tiled  = false,
--          {
--             widget    = wibox.widget.imagebox,
--             image     = gears.surface.crop_surface({
--                surface = beautiful.wallpaper,
--                ratio   = s.geometry.width / s.geometry.height
--             }),
--             upscale   = true,
--             downscale = true
--          }
--       }
--    })
-- end)
-- An example of what's mentioned above. For more information, see:
-- https://awesomewm.org/apidoc/utility_libraries/gears.wallpaper.html
require('gears').wallpaper.maximized(beautiful.wallpaper)
