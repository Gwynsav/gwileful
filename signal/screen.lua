local require, screen, table = require, screen, table

local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local user = require('config.user')

--- Attach tags and require('ui') to all screens.
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
   s.bar = require('ui.wibar')(s)
   s.launcher = require('ui.launcher')(s)

   -- And some other widgets only to the `main` screen.
   if s == awful.screen.focused() then
      s.dash = require('ui.dash')(s)
      s.time = require('ui.time')(s)
      s.osds = require('ui.osd')(s)
   end
end)

--- Wallpaper.
if not beautiful.solid_wallpaper then
   -- https://awesomewm.org/apidoc/utility_libraries/gears.wallpaper.html
   require('gears').wallpaper.maximized(beautiful.wallpaper)
else
   screen.connect_signal('request::wallpaper', function(s)
      awful.wallpaper({
         screen = s,
         widget = {
            widget = wibox.container.background,
            bg     = beautiful.wallpaper
         }
      })
   end)
end
