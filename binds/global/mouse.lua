local awful = require('awful')

local widgets = require('ui')

--- Global mouse bindings
awful.mouse.append_global_mousebindings({
   awful.button(nil, 3, function() widgets.menu.main:toggle() end),
   -- Single most annoying pair of keybinds ever to be seen.
   -- awful.button(nil, 4, awful.tag.viewprev),
   -- awful.button(nil, 5, awful.tag.viewnext)
})
