-- Writes Xresources using current colorscheme and a few other things, does not override
-- your `~/.Xresources` file, instead, it creates a `~/.local/share/gwileful/xresources`
-- file which is merged with your present configuration on AwesomeWM startup.
local require, io = require, io

local awful     = require('awful')
local beautiful = require('beautiful')

local color = require(beautiful.colorscheme)
local path =  beautiful.data_dir .. 'xresources'

local theme = string.format([[
Nsxiv.window.background: %s
Nsxiv.window.foreground: %s
Nsxiv.bar.background: %s
Nsxiv.bar.foreground: %s
Nsxiv.mark.foreground: %s
Nsxiv.bar.font: %s
]],
   color.bg0, color.accent, color.bg1, color.fg0, color.bccent,
   (beautiful.font_bitm .. beautiful.bitm_size):gsub(' ', '-')
)

return function()
   local file = io.open(path, 'w')
   -- Create file if it doesn't exist.
   if file == nil then
      awful.spawn.with_shell('mkdir -p ' .. beautiful.data_dir .. '; touch ' .. path)
      file = io.open(path, 'w')
   end
   -- If it was still somehow impossible to access the file, stop.
   if file == nil then return end

   -- Update Xresources.
   file:write(theme)
   file:close()
   awful.spawn('xrdb -override ' .. path)
end
