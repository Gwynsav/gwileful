local require, io = require, io

local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')

-- Themes define colors, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. 'theme/theme.lua')

-- Check that the colorscheme to be set is actually different than current.
-- If not, do nothing.
local last_path = beautiful.state_dir .. 'last_colorscheme'

local last = io.open(last_path, 'rb')
local colors = nil
if last == nil then
   awful.spawn.with_shell('mkdir -p ' .. beautiful.state_dir .. '; touch ' .. last_path)
else
   last:close()
   -- It only really has one line.
   local lines = {}
   for line in io.lines(last_path) do
      lines[#lines + 1] = line
   end
   colors = lines[1]
end
if colors == beautiful.colorscheme then return end

-- Set the tym colorscheme.
require('script.tym-themer')()
-- Merge the Xresources settings.
require('script.xresources')()

-- Update history file.
last = io.open(last_path, 'w')
if last == nil then return end
last:write(beautiful.colorscheme)
last:close()
