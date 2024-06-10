local awful = require('awful')
local gears = require('gears')

local volume_old, mute_old = -1, -1
local function report_output()
   awful.spawn.easy_async_with_shell(
      'bash -c "pactl get-sink-volume @DEFAULT_SINK@; pactl get-sink-mute @DEFAULT_SINK@"',
      function(out)
         local volume = tonumber(out:match('(%d+)%%')) or -1
         local mute   = out:match('Mute: yes') and 1 or 0
         if volume ~= volume_old or mute ~= mute_old then
            -- volume, % (0-100) of default sink level.
            -- mute, pseudo-boolean, 1 if muted, 0 if not.
            volume_old = volume
            mute_old   = mute
            awesome.emit_signal('audio::update', volume, mute)
         end
      end
   )
end

-- `gears.timer` is a non-blocking poll, but checking for updates this often is
-- inefficient given that you don't change your volume every other second but also want it
-- to respond somewhat quickly when you actually do update your volume... However, because
-- the functions for changing audio from within AwesomeWM (see `signal/system/audio.lua`)
-- produce the `audio::update` signal asynchronously, we can safely raise the timeout to a
-- value where we spend most of the time in this non-blocking wait instead of running
-- shell commands.
gears.timer({
   timeout   = 10,
   autostart = true,
   callback  = function()
      report_output()
   end
})
