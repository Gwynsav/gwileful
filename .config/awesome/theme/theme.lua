local gears = require('gears')

local gc  = gears.color
local gfs = gears.filesystem
local dpi = require('beautiful.xresources').apply_dpi

local user  = require('config.user')
local color = require('theme.color')
local colorscheme = color.palette
local icon        = gfs.get_configuration_dir() .. 'theme/assets/'

local _T = {}

-- Return the path to the file to avoid having to:
--   - 1: clone the entire colors table into beautiful.
--   - 2: having to run the `theme.color` logic every time.
-- This may have been a very smart or ridiculously stupid choice. We'll see.
_T.colorscheme = color.path

-- Fonts
_T.font_sans = 'IBM Plex Sans '
_T.font_mono = 'IBM Plex Mono '
_T.font_bitm = 'Fairfax '

-- A few defaults.
_T.font = _T.font_sans .. dpi(9)
_T.bg_normal = colorscheme.bg0
_T.fg_normal = colorscheme.fg0

-- Awesome Icon.
_T.awesome_icon = gc.recolor_image(icon .. 'awesome.svg', colorscheme.fg0)

-- WM
-----
_T.useless_gap  = user.gaps or dpi(6)
_T.master_width_factor = 0.58

-- Borders.
_T.border_width = user.border_size or dpi(1)
_T.border_color = colorscheme.bg1
_T.fullscreen_hide_border = true
_T.maximized_hide_border  = false

-- Titlebars. Recoloring these on the fly is gonna burn through your RAM at alarming
-- speeds.
_T.titlebar_close_focus  = gc.recolor_image(icon .. 'title/close.svg', colorscheme.fg0)
_T.titlebar_close_normal = gc.recolor_image(icon .. 'title/close.svg', colorscheme.fg1)
_T.titlebar_max_focus    = gc.recolor_image(icon .. 'title/max.svg',   colorscheme.fg0)
_T.titlebar_max_normal   = gc.recolor_image(icon .. 'title/max.svg',   colorscheme.fg1)
_T.titlebar_min_focus    = gc.recolor_image(icon .. 'title/min.svg',   colorscheme.fg0)
_T.titlebar_min_normal   = gc.recolor_image(icon .. 'title/min.svg',   colorscheme.fg1)

return _T
