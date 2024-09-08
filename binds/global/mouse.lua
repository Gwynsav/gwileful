local require = require

local awful = require('awful')

local menu = require('ui.menu')

--- Global mouse bindings
awful.mouse.append_global_mousebindings({
   awful.button(nil, 3, function() menu.main:toggle() end),
   -- Single most annoying pair of keybinds ever to be seen.
   -- awful.button(nil, 4, awful.tag.viewprev),
   -- awful.button(nil, 5, awful.tag.viewnext)
})
