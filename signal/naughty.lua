--- Notifications
-- Defines the default notification layout.
require('naughty').connect_signal('request::display', function(n)
   require('ui').notification.normal(n)
end)
