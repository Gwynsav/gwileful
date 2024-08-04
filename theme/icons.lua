local _I = { battery = {} }

_I.font = 'gwnce '
-- The glyphs are actually 9px tall.
_I.size = require('beautiful').xresources.apply_dpi(7)

-- Power.
_I['power_shutdown'] = ''
_I['power_reboot']   = ''
_I['power_suspend']  = ''
_I['power_logoff']   = ''
-- Battery.
_I.battery['UNKNOWN']  = ''
_I.battery['NONE']     = ''
_I.battery['CRITICAL'] = ''
_I.battery['LOW']      = ''
_I.battery['NORMAL']   = ''
_I.battery['HIGH']     = ''
_I.battery['FULL']     = ''
_I.battery['CHARGING'] = 'p'
_I.battery['CHARGED']  = ''

-- Network.
_I['net_wifi_high']    = ''
_I['net_wifi_normal']  = ''
_I['net_wifi_low']     = ''
_I['net_wifi_none']    = ''
_I['net_wired_normal'] = ''
_I['net_wired_none']   = ''
_I['net_none']         = ''
-- Bluetooth.
_I['bluez_off']      = ''
_I['bluez_scanning'] = ''
_I['bluez_on']       = ''

-- Media.
_I['music']          = ''
_I['music_previous'] = ''
_I['music_next']     = ''
_I['music_pause']    = ''
_I['music_play']     = ''
_I['music_loop']     = _I['power_reboot']
_I['music_shuffle']  = ''
-- Audio.
_I['audio_muted']    = ''
_I['audio_decrease'] = ''
_I['audio_increase'] = ''
-- Microphone.
_I['mic_muted']    = ''
_I['mic_decrease'] = ''
_I['mic_increase'] = ''

-- Arrows.
_I['arrow_up']    = ''
_I['arrow_right'] = ''
_I['arrow_down']  = ''
_I['arrow_left']  = ''
-- Miscelaneous.
_I['util_magnifier'] = ''
_I['util_hamburger'] = ''
-- Titlebar.
_I['title_pin']      = ''
_I['title_minimize'] = ''
_I['title_maximize'] = ''
_I['title_close']    = ''

return _I
