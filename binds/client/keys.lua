local awful = require('awful')

local mod    = require('binds.mod')
local modkey = mod.modkey
local tabbed = require('module.bling').module.tabbed

--- Client keybindings.
client.connect_signal('request::default_keybindings', function()
   awful.keyboard.append_client_keybindings({
      -- Client state management.
      awful.key({ modkey, mod.shift }, 'q', function(c) c:kill() end,
         { description = 'close', group = 'client' }),

      awful.key({ modkey,           }, 'space', awful.client.floating.toggle,
         { description = 'toggle floating', group = 'client' }),
      awful.key({ modkey,           }, 't', function(c) c.ontop = not c.ontop end,
         { description = 'toggle keep on top', group = 'client' }),
      awful.key({ modkey, mod.ctrl  }, 'space', function(c) c.sticky = not c.sticky end,
         { description = 'toggle sticky', group = 'client' }),

      awful.key({ modkey,           }, 'n',
         function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
         end, { description = 'minimize', group = 'client' }),
      awful.key({ modkey,           }, 'm',
         function(c)
            c.maximized = not c.maximized
            c:raise()
         end, { description = '(un)maximize', group = 'client' }),
      awful.key({ modkey,           }, 'f', function(c)
         c.fullscreen = not c.fullscreen
         c:raise()
      end, { description = 'toggle fullscreen', group = 'client' }),

      -- Bling Tabbed management.
      awful.key({ modkey, mod.shift }, 'h', function()
         tabbed.pick_by_direction('up')
      end, { description = 'add client above focused to group', group = 'tabbing' }),
      awful.key({ modkey, mod.shift }, 'l', function()
         tabbed.pick_by_direction('down')
      end, { description = 'add client below focused to group', group = 'tabbing' }),
      awful.key({ modkey }, 'Escape', function() tabbed.pop() end,
         { description = 'remove client from tabbed group', group = 'tabbing' }),
      awful.key({ modkey }, 'Tab', function() tabbed.iter() end,
         { description = 'cycle tabbed client focus', group = 'tabbing' })
   })
end)
