local gears = require('gears')

local gc  = gears.color
local gfs = gears.filesystem
local dpi = require('beautiful.xresources').apply_dpi

local user  = require('config.user')
local color = require('theme.color')
local colorscheme = color.palette
local icon        = gfs.get_configuration_dir() .. 'theme/assets/'

-- NOTE: try to keep all usages of `gears.color.recolor_image` within this file to prevent
-- it from being executed multiple times. It will burn through your RAM at alarming speed.
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
_T.font = _T.font_bitm .. dpi(9)
_T.bg_normal = colorscheme.bg0
_T.fg_normal = colorscheme.fg0

-- Awesome Icon.
_T.awesome_icon = gc.recolor_image(icon .. 'awesome.svg', colorscheme.fg0)

-- WM
-----
_T.useless_gap  = user.gaps or dpi(6)
_T.master_width_factor = 0.58

-- Borders.
_T.border_width = 0

-- Widgets
----------
-- Titlebars.
_T.titlebar_close_focus  = gc.recolor_image(icon .. 'title/close.svg',    colorscheme.fg0)
_T.titlebar_close_normal = gc.recolor_image(icon .. 'title/close.svg',    colorscheme.fg1)
_T.titlebar_max_focus    = gc.recolor_image(icon .. 'title/maximize.svg', colorscheme.fg0)
_T.titlebar_max_normal   = gc.recolor_image(icon .. 'title/maximize.svg', colorscheme.fg1)
_T.titlebar_min_focus    = gc.recolor_image(icon .. 'title/minimize.svg', colorscheme.fg0)
_T.titlebar_min_normal   = gc.recolor_image(icon .. 'title/minimize.svg', colorscheme.fg1)
_T.titlebar_pin_focus    = gc.recolor_image(icon .. 'title/command.svg',  colorscheme.fg0)
_T.titlebar_pin_normal   = gc.recolor_image(icon .. 'title/command.svg',  colorscheme.fg1)

-- Notifications.
-- TODO
-- _T.notification_default  = gc.recolor_image(icon .. 'notif/default.svg', colorscheme.fg0)
_T.notification_default  = _T.awesome_icon
-- _T.notification_cancel   = gc.recolor_image(icon .. 'notif/cancel.svg',  colorscheme.red)
_T.notification_cancel   = gc.recolor_image(icon .. 'awesome.svg',  colorscheme.red)

-- Wibar.
_T.systray_arrow = gc.recolor_image(icon .. 'wibar/systray_arrow.svg', colorscheme.fg0)
-- Layouts. Text is preferred for the horizontal version.
if user.bar_style == 'vertical' then
   _T.layout_tile =
      gc.recolor_image(icon .. 'wibar/layout/tile_right.svg',  colorscheme.fg0)
   _T.layout_tileleft =
      gc.recolor_image(icon .. 'wibar/layout/tile_left.svg',   colorscheme.fg0)
   _T.layout_tilebottom =
      gc.recolor_image(icon .. 'wibar/layout/tile_bottom.svg', colorscheme.fg0)
   _T.layout_floating =
      gc.recolor_image(icon .. 'wibar/layout/float.svg',       colorscheme.fg0)
end

return _T
