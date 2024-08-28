local gears = require('gears')

local gc  = gears.color
local gfs = gears.filesystem
local dpi = require('beautiful.xresources').apply_dpi

local user  = require('config.user')
local color = require('theme.color')
local colorscheme = color.palette
local asset        = gfs.get_configuration_dir() .. 'theme/assets/'

-- NOTE: try to keep all usages of `gears.color.recolor_image` within this file to prevent
-- it from being executed multiple times. It will burn through your RAM at alarming speed.
local _T = {}

-- Return the path to the file to avoid having to:
--   - 1: clone the entire colors table into beautiful.
--   - 2: having to run the `theme.color` logic every time.
-- This may have been a very smart or ridiculously stupid choice. We'll see.
_T.colorscheme = color.path
_T.pfp         = gears.surface.load_uncached(user.pfp or asset .. 'default/pfp.png')
_T.wallpaper   = gears.surface.load_uncached(user.wallpaper or asset .. 'default/wall.png')

-- Fonts
_T.font_bitm = 'satori '
_T.font_mono = 'koishi '
_T.bitm_size = dpi(9)

-- A few defaults.
_T.font = _T.font_bitm .. _T.bitm_size
_T.bg_normal = colorscheme.bg0
_T.fg_normal = colorscheme.fg0

-- Awesome Icon.
_T.awesome_icon = gc.recolor_image(asset .. 'util/awesome.png', colorscheme.fg0)

-- WM
-----
_T.useless_gap = user.gaps or dpi(6)
_T.master_width_factor = 0.58

-- Borders.
_T.border_width = 0

-- Widgets
----------
-- Notifications.
_T.notification_spacing = _T.useless_gap * 2
_T.notification_default = gc.recolor_image(asset .. 'notif/default.png', colorscheme.fg0)
_T.notification_cancel  = gc.recolor_image(asset .. 'notif/cancel.png',  colorscheme.red)

-- Tooltips.
_T.tooltip_border_color = colorscheme.bg3
_T.tooltip_border_width = dpi(1)
_T.tooltip_bg           = colorscheme.bg0
_T.tooltip_fg           = colorscheme.fg0

-- Systray.
_T.bg_systray           = colorscheme.bg1
_T.systray_icon_spacing = dpi(2)

-- Icons
--------
-- Layouts.
_T.layout_tile =
   gc.recolor_image(asset .. 'wibar/layout/tile_right.png',  colorscheme.fg0)
_T.layout_tileleft =
   gc.recolor_image(asset .. 'wibar/layout/tile_left.png',   colorscheme.fg0)
_T.layout_tilebottom =
   gc.recolor_image(asset .. 'wibar/layout/tile_bottom.png', colorscheme.fg0)
_T.layout_floating =
   gc.recolor_image(asset .. 'wibar/layout/float.png',       colorscheme.fg0)

-- Bling
--------
-- Tabbar.
_T.tabbar_disable = true

-- Tag Preview.
_T.tag_preview_widget_border_width = dpi(1)
_T.tag_preview_widget_margin       = _T.useless_gap
_T.tag_preview_widget_bg           = colorscheme.bg1
_T.tag_preview_widget_border_color = colorscheme.bg3
--- Clients.
_T.tag_preview_client_opacity      = 1
_T.tag_preview_client_border_width = dpi(1)
_T.tag_preview_client_bg           = colorscheme.bg0
_T.tag_preview_client_border_color = colorscheme.bg3

return _T
