local path = ...

return function(s)
   return {
      volume = require(path .. '.volume')(s)
   }
end
