-- local awful = require('awful')
local home = os.getenv('HOME')

local gtk3_path = home .. '/.config/gtk-3.0/settings.ini'
local gtk3_content = [[
[Settings]
gtk-cursor-theme-name=%s
]]

local gtk2_path = home .. '/.gtkrc-2.0'
local gtk2_content = [[
gtk-cursor-theme-name="%s"
]]

local default_path = home .. '/.local/share/icons/default'
local xresources_path = home .. '/.Xresources'

-- Sets the X cursor theme, likely requires restarting the X server.
-- @param cursor_path expects a path to a directory containing an index.theme file.
--        For example, `home .. '/.local/share/icons/Adwaita'`.
local function set_cursor(cursor_path)
   if cursor_path == nil then return end

   -- Check the path for its validity.
   local cursor_name = nil
   local cursor_file = io.open(cursor_path .. '/index.theme', 'r')
   if cursor_file == nil then
      cursor_file:close()
      return
   else
      -- It's impossible for the `Name` field to be the first line of an index.theme file.
      for line in cursor_file:lines(2) do
         if line:match('(Name=.+)') then
            cursor_name = line:gsub('Name=', '')
            break
         end
      end
      cursor_file:close()
   end
   -- If no fitting cursor theme is found then return.
   if cursor_name == nil then return end
   print('Found theme with name: ' .. cursor_name)

   -- Otherwise proceed to setting the theme.
   -- GTK 3.0.
   local gtk3_config = io.open(gtk3_path, 'r')
   if gtk3_config then
      print('GTK3 config file found!')
      gtk3_config:close()
      os.execute(string.format([[
         sed -i "s/^gtk-cursor-theme-name=.*$/gtk-cursor-theme-name=%s/" %s 
      ]], cursor_name, gtk3_path))
   else
      print('GTK3 config file NOT found!')
      gtk3_config = io.open(gtk3_path, 'w')
      gtk3_config:write(string.format(gtk3_content, cursor_name))
      gtk3_config:close()
   end

   -- GTK 2.0.
   local gtk2_config = io.open(gtk2_path, 'r')
   if gtk2_config then
      print('GTK2 config file found!')
      gtk2_config:close()
      os.execute(string.format([[
         sed -i "s/^gtk-cursor-theme-name=.*$/gtk-cursor-theme-name=\"%s\"/" %s 
      ]], cursor_name, gtk2_path))
   else
      print('GTK2 config file NOT found!')
      gtk2_config = io.open(gtk2_path, 'w')
      gtk2_config:write(string.format(gtk2_content, cursor_name))
      gtk2_config:close()
   end

   -- Default (used by, for example, Qt).
   os.remove(home .. '/.local/share/icons/default')
   os.execute('ln -s ' .. cursor_path .. ' ' .. default_path)

   -- X.
   local xresources = io.open(xresources_path, 'a+')
   xresources:write(string.format([[
Xcursor.theme: %s
   ]], cursor_name))
   xresources:close()
   os.execute('xrdb ' .. home .. '/.Xresources')

   os.execute('xsetroot -cursor_name left_ptr')
end

set_cursor(home .. '/.local/share/icons/pixelfun3')
