--- Notifications

-- Something particularly odd about naughty is that you must set position and screen
-- setting through ruled, since trying to do that on the `naughty.notification.layout_box`
-- directly will result in some really buggy behavior. Even more weirdly, notification
-- margins must be set through a `beautiful` variable (in `theme/theme.lua`).
local ruled = require('ruled')
ruled.notification.connect_signal('request::rules', function()
   ruled.notification.append_rule({
      rule = {},
      properties = {
         position = 'bottom_right'
      }
   })
end)

-- Defines the default notification layout. Given I have OSDs now, special notifications
-- won't be a necessity.
require('naughty').connect_signal('request::display', function(n)
   require('ui.notification')(n)
end)
