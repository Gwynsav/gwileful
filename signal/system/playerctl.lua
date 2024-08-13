local instance = nil

local function new()
   return require('module.bling').signal.playerctl.lib({
      player = { 'mpd', '%any', 'firefox' },
      pctl_update_on_activity = true,
      pctl_position_update_interval = 1
   })
end

if not instance then
   instance = new()
end

return instance
