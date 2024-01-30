-- Add a titlebar if titlebars_enabled is set to true for the client in `config/rules.lua`.
client.connect_signal('request::titlebars', function(c)
   -- Some clients don't actually want to have a titlebar.
   if c.requests_no_titlebar and c.class ~= 'com.github.taiko2k.tauonmb' then
      return
   end

   require('ui.titlebar').normal(c)
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal('mouse::enter', function(c)
--    c:activate({ context = 'mouse_enter', raise = false })
-- end)
