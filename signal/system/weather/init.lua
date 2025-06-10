local instance = nil

if not instance then
   instance = require(... .. ".provider")
end

return instance
