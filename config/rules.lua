local awful = require('awful')
local ruled = require('ruled')

local user  = require('config.user')

--- Rules.
-- Rules to apply to new clients.
ruled.client.connect_signal('request::rules', function()
   -- All clients will match this rule.
   ruled.client.append_rule({
      id         = 'global',
      rule       = { },
      properties = {
         focus     = awful.client.focus.filter,
         raise     = true,
         screen    = awful.screen.preferred,
         placement = awful.placement.centered + awful.placement.no_offscreen,
         callback  = awful.client.setslave,
         size_hints_honor = false
      }
   })

   -- Floating clients.
   ruled.client.append_rule({
      id       = 'floating',
      rule_any = {
         instance = { 'copyq', 'pinentry' },
         class    = {
            'Arandr', 'Blueman-manager', 'Gpick', 'Kruler', 'Sxiv',
            'Tor Browser', 'Wpa_gui', 'veromix', 'xtightvncviewer',
            'Nsxiv', 'mpv'
         },
         -- Note that the name property shown in xprop might be set slightly after
         -- creation of the client and the name shown there might not match defined rules
         -- here.
         name    = {
            'Event Tester'   -- xev.
         },
         role    = {
            'AlarmWindow',   -- Thunderbird's calendar.
            'ConfigManager', -- Thunderbird's about:config.
            'pop-up'         -- e.g. Google Chrome's (detached) Developer Tools.
         }
      },
      properties = { floating = true }
   })

   -- Add titlebars to normal clients and dialogs.
   ruled.client.append_rule({
      id         = 'titlebars',
      rule_any   = { type = { 'normal', 'dialog' } },
      properties = { titlebars_enabled = true      }
   })

   -- Map certain clients to certain workspaces.
   ruled.client.append_rule({
      rule_any = {
         class = { 'Steam', 'Heroic' }
      },
      properties = { screen = 1, tag = tostring(user.tags) }
   })
   ruled.client.append_rule({
      rule_any = {
         class = { 'Discord', 'vesktop' }
      },
      properties = { screen = 1, tag = tostring(user.tags - 1) }
   })
end)

-- Floating windows are `always on top` by default.
client.connect_signal("property::floating", function(c) c.ontop = c.floating end)
