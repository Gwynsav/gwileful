local gears = require('gears')
local cairo = require('lgi').cairo

local _H = {}

-- Blyaticon's image cropping function, uses a cairo surface which it crops to a ratio.
-- https://git.gemia.net/paul.s/homedots/-/blob/main/awesome/helpers.lua#L133
function _H.crop_surface(ratio, surf)
   local old_w, old_h = gears.surface.get_size(surf)
   local old_ratio    = old_w / old_h
   if old_ratio == ratio then return surf end

   local new_w = old_w
   local new_h = old_h
   local offset_w, offset_h = 0, 0
   -- quick mafs
   if (old_ratio < ratio) then
      new_h    = math.ceil(old_w * (1 / ratio))
      offset_h = math.ceil((old_h - new_h) / 2)
   else
      new_w    = math.ceil(old_h * ratio)
      offset_w = math.ceil((old_w - new_w) / 2)
   end

   local out_surf = cairo.ImageSurface(cairo.Format.ARGB32, new_w, new_h)
   local cr       = cairo.Context(out_surf)
   cr:set_source_surface(surf, -offset_w, -offset_h)
   cr.operator    = cairo.Operator.SOURCE
   cr:paint()

   return out_surf
end

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

return _H
