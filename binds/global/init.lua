-- Returns all global WM mouse and keybinds.
local require = require
return {
   keys  = require(... .. '.keys'),
   mouse = require(... .. '.mouse')
}
