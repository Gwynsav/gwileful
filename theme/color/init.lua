local require = require

local user = require('config.user')

local colorscheme = user.colorscheme or 'rose-pine'
local style = user.style or 'dark'

local path = 'theme.color.' .. colorscheme .. '.' .. style
local palette = require(path)
palette.transparent = '#00000000'

return {
   palette = palette,
   path    = path
}
