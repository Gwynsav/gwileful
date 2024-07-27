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
_T.notification_spacing  = _T.useless_gap * 2
_T.notification_default  = gc.recolor_image(icon .. 'notif/default.png', colorscheme.fg0)
_T.notification_cancel   = gc.recolor_image(icon .. 'notif/cancel.png',  colorscheme.red)

-- Tooltips.
_T.tooltip_border_color = colorscheme.bg3
_T.tooltip_border_width = dpi(1)
_T.tooltip_bg           = colorscheme.bg0
_T.tooltip_fg           = colorscheme.fg0

-- Icons
--------
_T.def_pfp     = icon .. 'default/pfp.png'
_T.hamburger   = gc.recolor_image(icon .. 'util/hamburger.png',     colorscheme.fg0)
_T.search      = gc.recolor_image(icon .. 'util/search.png',        colorscheme.fg0)
_T.search_hl   = gc.recolor_image(icon .. 'util/search.png',        colorscheme.accent)
-- These are actually just arrows, the naming has become outdated and I'm too lazy to go around
-- the whole code correcting it. They're used for more than just the systray.
_T.arrow       = gc.recolor_image(icon .. 'util/arrow.png',         colorscheme.fg0)
_T.arrow_ng    = gc.recolor_image(icon .. 'util/arrow.png',         colorscheme.bg0)
-- Power icons.
_T.shutdown    = gc.recolor_image(icon .. 'power/shutdown.png',     colorscheme.fg0)
_T.shutdown_hl = gc.recolor_image(icon .. 'power/shutdown.png',     colorscheme.red)
_T.reboot      = gc.recolor_image(icon .. 'power/reboot.png',       colorscheme.fg0)
_T.reboot_hl   = gc.recolor_image(icon .. 'power/reboot.png',       colorscheme.red)
_T.suspend     = gc.recolor_image(icon .. 'power/suspend.png',      colorscheme.fg0)
_T.suspend_hl  = gc.recolor_image(icon .. 'power/suspend.png',      colorscheme.red)
_T.logoff      = gc.recolor_image(icon .. 'power/logoff.png',       colorscheme.fg0)
_T.logoff_hl   = gc.recolor_image(icon .. 'power/logoff.png',       colorscheme.red)
-- Audio.
_T.vol_up      = gc.recolor_image(icon .. 'status/volume/up.png',   colorscheme.fg0)
_T.vol_up_hl   = gc.recolor_image(icon .. 'status/volume/up.png',   colorscheme.accent)
_T.vol_down    = gc.recolor_image(icon .. 'status/volume/down.png', colorscheme.fg0)
_T.vol_off     = gc.recolor_image(icon .. 'status/volume/off.png',  colorscheme.red)
_T.mic_up      = gc.recolor_image(icon .. 'status/mic/up.png',      colorscheme.fg0)
_T.mic_up_hl   = gc.recolor_image(icon .. 'status/mic/up.png',      colorscheme.accent)
_T.mic_down    = gc.recolor_image(icon .. 'status/mic/down.png',    colorscheme.fg0)
_T.mic_off     = gc.recolor_image(icon .. 'status/mic/off.png',     colorscheme.red)
-- Music.
_T.song        = gc.recolor_image(icon .. 'player/song.png',        colorscheme.fg1)
_T.play        = gc.recolor_image(icon .. 'player/play.png',        colorscheme.fg0)
_T.play_hl     = gc.recolor_image(icon .. 'player/play.png',        colorscheme.accent)
_T.back        = gc.recolor_image(icon .. 'player/back.png',        colorscheme.fg0)
_T.back_hl     = gc.recolor_image(icon .. 'player/back.png',        colorscheme.accent)
_T.forward     = gc.recolor_image(icon .. 'player/forward.png',     colorscheme.fg0)
_T.forward_hl  = gc.recolor_image(icon .. 'player/forward.png',     colorscheme.accent)
_T.shuffle     = gc.recolor_image(icon .. 'player/shuffle.png',     colorscheme.fg0)
_T.shuffle_hl  = gc.recolor_image(icon .. 'player/shuffle.png',     colorscheme.accent)
_T.loop        = gc.recolor_image(icon .. 'power/reboot.png',       colorscheme.fg0)
_T.loop_hl     = gc.recolor_image(icon .. 'power/reboot.png',       colorscheme.accent)
-- Network.
_T.network     = gc.recolor_image(icon .. 'net/up.png',             colorscheme.fg0)
_T.network_hl  = gc.recolor_image(icon .. 'net/up.png',             colorscheme.accent)
-- Bluetooth.
_T.bluetooth    = gc.recolor_image(icon .. 'bluetooth/up.png',      colorscheme.fg0)
_T.bluetooth_hl = gc.recolor_image(icon .. 'bluetooth/up.png',      colorscheme.accent)
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
