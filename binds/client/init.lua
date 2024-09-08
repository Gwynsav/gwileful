-- Returns all client mouse and keybinds.
local require = require
return {
   keys  = require(... .. '.keys'),
   mouse = require(... .. '.mouse')
}
