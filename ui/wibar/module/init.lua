-- Return a table containing all bar modules, with a name attached
-- to each.
local require = require
local path = ... .. '.'
return setmetatable({}, {
   __index = function(_, key)
      local module, _ = require(path .. key)
      return module
   end
})
