-- Writes a tym colorcheme using current colorscheme.

local c = require(require('beautiful').colorscheme)

local theme = string.format([[
   return {
      color_window_background = "%s",
      color_cursor_foreground = "%s",
      color_background        = "%s",
      color_0                 = "%s",
      color_foreground        = "%s",
      color_7                 = "%s",
      color_bold              = "%s",
      color_8                 = "%s",
      color_15                = "%s",
      color_cursor            = "%s",
      color_9                 = "%s",
      color_1                 = "%s",
      color_10                = "%s",
      color_2                 = "%s",
      color_11                = "%s",
      color_3                 = "%s",
      color_12                = "%s",
      color_4                 = "%s",
      color_13                = "%s",
      color_5                 = "%s",
      color_14                = "%s",
      color_6                 = "%s"
   }
   ]],
   c.bg0, c.bg0, c.bg0, c.bg0, c.fg0, c.fg2, c.fg0, c.bg2, c.fg0, c.fg0,
   c.red, c.red, c.green, c.green, c.blue, c.blue, c.yellow, c.yellow,
   c.magenta, c.magenta, c.cyan, c.cyan
)

return function()
   local file = io.open(os.getenv('HOME') .. '/.config/tym/theme.lua', 'w+')
   if file == nil then return end
   file:write(theme)
   file:close()
end
