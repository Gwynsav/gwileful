-- Writes a Xresources using current colorscheme and a few other things.

local awful     = require('awful')
local beautiful = require('beautiful')

local c = require(beautiful.colorscheme)
local path = os.getenv('HOME') .. '/.Xresources'

local theme = string.format([[
*.dpi: %d
Nsxiv.window.background: %s
Nsxiv.window.foreground: %s
Nsxiv.bar.background: %s
Nsxiv.bar.foreground: %s
Nsxiv.mark.foreground: %s
Nsxiv.bar.font: %s
Xcursor.theme: Miku Cursor
]],
   awful.screen.focused().dpi,
   c.bg0, c.accent, c.bg1, c.fg0, c.bccent,
   (beautiful.font_bitm .. beautiful.bitm_size):gsub(' ', '-')
)

return function()
   local file = io.open(path, 'w')
   if file == nil then return end
   file:write(theme)
   file:close()
   awful.spawn.with_shell('xrdb -override ' .. path)
end
