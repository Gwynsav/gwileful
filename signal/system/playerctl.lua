local instance = nil

local function new()
   return require('module.bling').signal.playerctl.lib({
      player = { 'mpd', '%any' },
      ignore = { 'firefox' },
      update_on_activity = true,
      interval = 1,
      debounce_delay = 0.35
   })
end

if not instance then
   instance = new()
end

return instance
