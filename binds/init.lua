-- Returns all mouse and keybinds for both clients and the WM.
local require = require
return {
   global = require(... .. '.global'),
   client = require(... .. '.client')
}

