local awful = require('awful')

local dpi = require('beautiful.xresources').apply_dpi

-- Specify user preferences for Awesome's behavior.
return {
   -- Default modkey.
   -- Usually, Mod4 is the key with a logo between Control and Alt. If you do not like 
   -- this or do not have such a key, I suggest you to remap Mod4 to another key using 
   -- xmodmap or other tools. However, you can use another modifier like Mod1, but it 
   -- may interact with others.
   mod  = 'Mod4',
   -- Each screen has its own tag table. You can just define one and append it to all 
   -- screens (default behavior).
   tags = 7,
   -- Table of layouts to cover with awful.layout.inc, ORDER MATTERS, the first layout 
   -- in the table is your DEFAULT LAYOUT.
   layouts = {
      awful.layout.suit.tile,
      awful.layout.suit.tile.left,
      awful.layout.suit.tile.bottom,
      -- awful.layout.suit.tile.top,
      -- awful.layout.suit.fair,
      -- awful.layout.suit.fair.horizontal,
      -- awful.layout.suit.spiral,
      -- awful.layout.suit.spiral.dwindle,
      -- awful.layout.suit.max,
      -- awful.layout.suit.max.fullscreen,
      -- awful.layout.suit.magnifier,
      -- awful.layout.suit.corner.nw,
      awful.layout.suit.floating
   },

   -- Sizes
   gaps = dpi(3),
   border_size = dpi(2),

   -- Colors
   colorscheme = 'rose-pine',
   style = 'dark',

   -- Wallpaper
   wallpaper = os.getenv('HOME') .. '/Pictures/walls/rose-pine/CozyReading.png'
}
