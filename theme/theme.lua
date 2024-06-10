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
_T.awesome_icon = gc.recolor_image(icon .. 'util/awesome.png', colorscheme.fg0)

-- WM
-----
_T.useless_gap  = user.gaps or dpi(6)
_T.master_width_factor = 0.58

-- Borders.
_T.border_width = 0

-- Widgets
----------
-- Titlebars.
_T.titlebar_close_hover  = gc.recolor_image(icon .. 'title/close.png',    colorscheme.red)
_T.titlebar_close_focus  = gc.recolor_image(icon .. 'title/close.png',    colorscheme.fg0)
_T.titlebar_max_hover    = gc.recolor_image(icon .. 'title/maximize.png', colorscheme.accent)
_T.titlebar_max_focus    = gc.recolor_image(icon .. 'title/maximize.png', colorscheme.fg0)
_T.titlebar_min_hover    = gc.recolor_image(icon .. 'title/minimize.png', colorscheme.accent)
_T.titlebar_min_focus    = gc.recolor_image(icon .. 'title/minimize.png', colorscheme.fg0)
_T.titlebar_pin_hover    = gc.recolor_image(icon .. 'title/command.png',  colorscheme.accent)
_T.titlebar_pin_focus    = gc.recolor_image(icon .. 'title/command.png',  colorscheme.fg0)

-- Notifications.
-- TODO
-- _T.notification_default  = gc.recolor_image(icon .. 'notif/default.svg', colorscheme.fg0)
_T.notification_default  = _T.awesome_icon
-- _T.notification_cancel   = gc.recolor_image(icon .. 'notif/cancel.svg',  colorscheme.red)
_T.notification_cancel   = gc.recolor_image(icon .. 'util/awesome.png',  colorscheme.red)

-- Tooltips.
_T.tooltip_border_color = colorscheme.bg3
_T.tooltip_border_width = dpi(1)
_T.tooltip_bg           = colorscheme.bg0
_T.tooltip_fg           = colorscheme.fg0

-- Icons
--------
_T.def_pfp     = icon .. 'default/pfp.png'
-- These are actually just arrows, the naming has become outdated and I'm too lazy to go around
-- the whole code correcting it. They're used for more than just the systray.
_T.arrow       = gc.recolor_image(icon .. 'util/arrow.png',     colorscheme.fg0)
_T.arrow_ng    = gc.recolor_image(icon .. 'util/arrow.png',     colorscheme.bg0)
-- Power icons.
_T.shutdown    = gc.recolor_image(icon .. 'power/shutdown.png', colorscheme.fg0)
_T.shutdown_ng = gc.recolor_image(icon .. 'power/shutdown.png', colorscheme.bg0)
_T.reboot      = gc.recolor_image(icon .. 'power/reboot.png',   colorscheme.fg0)
_T.reboot_ng   = gc.recolor_image(icon .. 'power/reboot.png',   colorscheme.bg0)
_T.logoff      = gc.recolor_image(icon .. 'power/logoff.png',   colorscheme.fg0)
_T.logoff_ng   = gc.recolor_image(icon .. 'power/logoff.png',   colorscheme.bg0)
-- Layouts.
_T.layout_tile =
   gc.recolor_image(icon .. 'wibar/layout/tile_right.png',  colorscheme.fg0)
_T.layout_tileleft =
   gc.recolor_image(icon .. 'wibar/layout/tile_left.png',   colorscheme.fg0)
_T.layout_tilebottom =
   gc.recolor_image(icon .. 'wibar/layout/tile_bottom.png', colorscheme.fg0)
_T.layout_floating =
   gc.recolor_image(icon .. 'wibar/layout/float.png',       colorscheme.fg0)

-- Bling
--------
-- Tabbar.
_T.tabbar_disable = true

return _T
