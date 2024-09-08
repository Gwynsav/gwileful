local _H = {}

-- I feel like YanDev saying "I wish there was a better way to do this"...
-- Gets the suffix for any given day of the month.
function _H.get_suffix(day)
   if day > 3 and day < 21 then
      return 'th'
   end

   if day % 10 == 1 then
      return 'st'
   elseif day % 10 == 2 then
      return 'nd'
   elseif day % 10 == 3 then
      return 'rd'
   else
      return 'th'
   end
end

-- Returns true when `e` is an entry in `table`.
function _H.in_table(e, table)
   for _, v in table do
      if v == e then
         return true
      end
   end
   return false
end

-- Check whether a file exists.
function _H.file_exists(path)
   return os.rename(path, path)
end

-- Check whether a directory exists.
function _H.dir_exists(path)
   if path:sub(-1, -1) ~= '/' then
      path = path .. '/'
   end
   return _H.file_exists(path)
end

return _H
