local require, awesome, client = require, awesome, client

local awful = require('awful')

local mod    = require('binds.mod')
local modkey = mod.modkey

local apps    = require('config.apps')
local audio   = require('signal.system.audio')
local pctl    = require('signal.system.playerctl')
local shooter = require('script.shooter')
local scratch = require('ui.scratch')

--- Global key bindings
awful.keyboard.append_global_keybindings({
   -- AwesomeWM
   ------------
   -- General Awesome keys.
   awful.key({ modkey,           }, 's', require('awful.hotkeys_popup').show_help,
      { description = 'show help', group = 'awesome' }),
   awful.key({ modkey, mod.ctrl  }, 'r', awesome.restart,
      { description = 'reload awesome', group = 'awesome' }),
   awful.key({ modkey,           }, 'Return', function() awful.spawn(apps.terminal) end,
      { description = 'open a terminal', group = 'launcher' }),
   awful.key({ modkey,           }, 'p', function() awful.screen.focused().launcher:open() end,
      { description = 'show the launcher', group = 'launcher' }),

   -- Focus related keybindings.
   awful.key({ modkey,           }, 'j', function() awful.client.focus.byidx( 1) end,
      { description = 'focus next by index', group = 'client' }),
   awful.key({ modkey,           }, 'k', function() awful.client.focus.byidx(-1) end,
      { description = 'focus previous by index', group = 'client'}),
   awful.key({ modkey, mod.ctrl }, 'Left', function() awful.screen.focus_relative( 1) end,
      { description = 'focus the next screen', group = 'screen' }),
   awful.key({ modkey, mod.ctrl }, 'Right', function() awful.screen.focus_relative(-1) end,
      { description = 'focus the previous screen', group = 'screen' }),

   -- Layout related keybindings.
   awful.key({ modkey, mod.shift }, 'j', function() awful.client.swap.byidx( 1) end,
      { description = 'swap with next client by index', group = 'client' }),
   awful.key({ modkey, mod.shift }, 'k', function() awful.client.swap.byidx(-1) end,
      { description = 'swap with previous client by index', group = 'client' }),
   awful.key({ modkey,           }, 'l', function() awful.tag.incmwfact( 0.05) end,
      { description = 'increase master width factor', group = 'layout' }),
   awful.key({ modkey,           }, 'h', function() awful.tag.incmwfact(-0.05) end,
      { description = 'decrease master width factor', group = 'layout' }),
   awful.key({ modkey,           }, 'equal', function() awful.tag.incnmaster( 1, nil, true) end,
      { description = 'increase the number of master clients', group = 'layout' }),
   awful.key({ modkey,           }, 'minus', function() awful.tag.incnmaster(-1, nil, true) end,
      { description = 'decrease the number of master clients', group = 'layout' }),
   awful.key({ modkey, mod.alt   }, 'k', function() awful.client.incwfact( 0.05) end,
      { description = 'increase client width factor', group = 'layout' }),
   awful.key({ modkey, mod.alt   }, 'j', function() awful.client.incwfact(-0.05) end,
      { description = 'decrease client width factor', group = 'layout' }),
   awful.key({ modkey, mod.ctrl  }, 'equal', function() awful.tag.incncol( 1, nil, true)
   end,{ description = 'increase the number of columns', group = 'layout' }),
   awful.key({ modkey, mod.ctrl  }, 'minus', function() awful.tag.incncol(-1, nil, true)
   end, { description = 'decrease the number of columns', group = 'layout' }),
   awful.key({
      modifiers   = { modkey },
      keygroup    = 'numrow',
      description = 'only view tag',
      group       = 'tag',
      on_press    = function(index)
         local tag = awful.screen.focused().tags[index]
         if tag then tag:view_only() end
      end
   }),
   awful.key({
      modifiers   = { modkey, mod.ctrl },
      keygroup    = 'numrow',
      description = 'toggle tag',
      group       = 'tag',
      on_press    = function(index)
         local tag = awful.screen.focused().tags[index]
         if tag then awful.tag.viewtoggle(tag) end
      end
   }),
   awful.key({
      modifiers   = { modkey, mod.shift },
      keygroup    = 'numrow',
      description = 'move focused client to tag',
      group       = 'tag',
      on_press    = function(index)
         if client.focus then
            local tag = client.focus.screen.tags[index]
            if tag then client.focus:move_to_tag(tag) end
         end
      end
   }),
   awful.key({
      modifiers   = { modkey, mod.ctrl, mod.shift },
      keygroup    = 'numrow',
      description = 'toggle focused client on tag',
      group       = 'tag',
      on_press    = function(index)
         if client.focus then
            local tag = client.focus.screen.tags[index]
            if tag then client.focus:toggle_tag(tag) end
         end
      end
   }),
   awful.key({
      modifiers   = { modkey, mod.alt },
      keygroup    = 'numrow',
      description = 'select layout directly',
      group       = 'layout',
      on_press    = function(index)
         local t = awful.screen.focused().selected_tag
         if t then
            t.layout = t.layouts[index] or t.layout
         end
      end
   }),

   -- Miscelaneous
   ---------------
   -- Screenshot.
   awful.key({          }, 'Print', function() shooter.selection() end,
      { description = 'select a region to screenshot', group = 'screenshot' }),
   awful.key({ modkey   }, 'Print', function() shooter.screen() end,
      { description = 'select the whole screen to screenshot', group = 'screenshot' }),
   awful.key({ mod.ctrl }, 'Print', function() shooter.delayed(5) end,
      { description = 'take a delayed fullscreen screenshot', group = 'screenshot' }),

   -- Audio.
   awful.key({          }, 'XF86AudioRaiseVolume', function() audio:default_sink_volume_up(2) end,
      { description = 'raises default audio device volume', group = 'audio' }),
   awful.key({          }, 'XF86AudioLowerVolume', function() audio:default_sink_volume_down(2) end,
      { description = 'lowers default audio device volume', group = 'audio' }),
   awful.key({          }, 'XF86AudioMute', function() audio:default_sink_toggle_mute() end,
      { description = 'toggles default audio device mute', group = 'audio' }),

   -- Music.
   awful.key({          }, 'XF86AudioPlay', function() pctl:play_pause() end,
      { description = 'toggles music playback', group = 'music' }),
   awful.key({          }, 'XF86AudioPrev', function() pctl:previous() end,
      { description = 'rewinds to previous song', group = 'music' }),
   awful.key({          }, 'XF86AudioNext', function() pctl:next() end,
      { description = 'skips to next song', group = 'music' }),
   awful.key({ modkey   }, 'o', function() scratch.music:toggle() end,
      { description = 'toggles music scratchpad', group = 'music' })
})
