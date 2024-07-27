local wibox = require('wibox')

local _H = {}

-- Crylia's app icon fetching function. Scans `/usr/share/icons` for application
-- icons of a set theme and application. Otherwise defaults to Papirus. Requires
-- `/usr/share/icons/Papirus-Dark` to exist to work as intended.
-- https://github.com/Crylia/crylia-theme/blob/main/awesome/src/tools/icon_handler.lua
local icon_cache = {}
-- Define a default icon.
_H.DEFAULT_ICON = '/usr/share/icons/Papirus-Dark/128x128/apps/application-default-icon.svg'
function _H.get_icon(theme, client, program_string, class_string)
   theme = theme or 'Papirus'
   client = client or nil
   program_string = program_string or nil
   class_string = class_string or nil

   if client or program_string or class_string then
      local clientName
      if client then
         if client.class then
            clientName = string.lower(client.class:gsub(' ', '')) .. '.svg'
         elseif client.name then
            clientName = string.lower(client.name:gsub(' ', '')) .. '.svg'
         else
            if client.icon then
               return client.icon
            else
               return _H.DEFAULT_ICON
            end
         end
      else
         if program_string then
            clientName = program_string .. '.svg'
         else
            clientName = class_string .. '.svg'
         end
      end

      for _, icon in ipairs(icon_cache) do
         if icon:match(clientName) then
            return icon
         end
      end

      local resolutions = {
         -- This is the format Papirus follows.
         '128x128', '96x96', '64x64', '48x48', '42x42', '32x32', '24x24', '16x16'
      }
      for _, res in ipairs(resolutions) do
         local iconDir = '/usr/share/icons/' .. theme .. '/' .. res .. '/apps/'
         local ioStream = io.open(iconDir .. clientName, 'r')
         if ioStream ~= nil then
            icon_cache[#icon_cache + 1] = iconDir .. clientName
            return iconDir .. clientName
         else
            clientName = clientName:gsub('^%l', string.upper)
            iconDir = '/usr/share/icons/' .. theme .. '/' .. res .. '/apps/'
            ioStream = io.open(iconDir .. clientName, 'r')
            if ioStream ~= nil then
               icon_cache[#icon_cache + 1] = iconDir .. clientName
               return iconDir .. clientName
            elseif not class_string then
               return _H.DEFAULT_ICON
            else
               clientName = class_string .. '.svg'
               iconDir = '/usr/share/icons/' .. theme .. '/' .. res .. '/apps/'
               ioStream = io.open(iconDir .. clientName, 'r')
               if ioStream ~= nil then
                  icon_cache[#icon_cache + 1] = iconDir .. clientName
                  return iconDir .. clientName
               else
                  return _H.DEFAULT_ICON
               end
            end
         end
      end
      if client then
         return _H.DEFAULT_ICON
      end
   end
end

-- Makes a colored textbox.
function _H.ctext(text, font, color)
   return wibox.widget({
      widget = wibox.container.background,
      fg     = color,
      {
         widget = wibox.widget.textbox,
         text   = text,
         font   = font,
         id     = 'text_role'
      },
      set_text = function(self, new_text)
         self:get_children_by_id('text_role')[1].text = new_text
      end
   })
end

-- Makes a scrolling text container.
function _H.stext(text, font, color)
   return wibox.widget({
      widget = wibox.container.scroll.horizontal,
      step_function =
         wibox.container.scroll.step_functions.waiting_nonlinear_back_and_forth,
      speed = 100,
      {
         widget = _H.ctext(text, font, color),
         id     = 'text_role'
      },
      set_text = function(self, new_text)
         self:get_children_by_id('text_role')[1].text = new_text
      end
   })
end

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

return _H
