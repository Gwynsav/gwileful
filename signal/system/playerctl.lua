return require('module.bling').signal.playerctl.lib({
   player = { 'mpd', '%any', 'firefox' },
   pctl_update_on_activity = true,
   pctl_position_update_interval = 1
})
