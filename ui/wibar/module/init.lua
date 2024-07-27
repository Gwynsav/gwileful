-- Return a table containing all bar modules, with a name attached
-- to each.
return {
   dash      = require(... .. '.dash'),
   taglist   = require(... .. '.taglist'),
   tasklist  = require(... .. '.tasklist'),
   layoutbox = require(... .. '.layoutbox'),
   clock     = require(... .. '.clock'),
   systray   = require(... .. '.systray'),
   status    = require(... .. '.status'),
   launcher  = require(... .. '.launcher')
}
