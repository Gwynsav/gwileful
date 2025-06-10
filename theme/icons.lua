local _I = {
   battery = {},
   weather = {},
   network = {},
   layout  = {}
}

_I.font = 'gwnce '
-- The glyphs are actually 9px tall.
_I.size = require('beautiful').xresources.apply_dpi(9)

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
_I.battery['CHARGING'] = ''
_I.battery['CHARGED']  = ''

-- Weather.
_I.weather['day_clear']           = ''
_I.weather['day_partly_cloudy']   = ''
_I.weather['day_cloudy']          = ''
_I.weather['day_light_rain']      = ''
_I.weather['day_rain']            = ''
_I.weather['day_storm']           = ''
_I.weather['day_snow']            = ''
_I.weather['day_fog']             = ''
_I.weather['night_clear']         = ''
_I.weather['night_partly_cloudy'] = ''
_I.weather['night_cloudy']        = ''
_I.weather['night_light_rain']    = ''
_I.weather['night_rain']          = ''
_I.weather['night_storm']         = ''
_I.weather['night_snow']          = ''
_I.weather['night_fog']           = ''

-- Network.
_I.network['wifi_high']    = ''
_I.network['wifi_normal']  = ''
_I.network['wifi_low']     = ''
_I.network['wifi_none']    = ''
_I.network['wired_normal'] = ''
_I.network['wired_none']   = ''
_I.network['none']         = ''
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

-- Titlebar.
_I['title_pin']      = ''
_I['title_minimize'] = ''
_I['title_maximize'] = ''
_I['title_close']    = ''
-- Layout.
_I.layout['floating']   = ''
_I.layout['tile']       = ''
_I.layout['tileleft']   = ''
_I.layout['tilebottom'] = ''

-- Arrows.
_I['arrow_up']    = ''
_I['arrow_right'] = ''
_I['arrow_down']  = ''
_I['arrow_left']  = ''
-- Miscelaneous.
_I['util_magnifier'] = ''
_I['util_hamburger'] = ''

return _I
