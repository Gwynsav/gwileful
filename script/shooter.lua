-- Screenshot script using maim and xclip. `awful.screenshot` has yet to be
-- reliable enough to be usable.

local awful     = require('awful')
local beautiful = require('beautiful')
local naughty   = require('naughty')

local user      = require('config.user')

-- The directory where PERMANENT files would be stored.
local perm_dir  = user.screenshot_path or os.getenv('HOME')

local function send_notif(path)
   local ok      = naughty.action({ name = 'Ok'      })
   local save    = naughty.action({ name = 'Save'    })
   local discard = naughty.action({ name = 'Discard' })

   save:connect_signal('invoked', function()
      awful.spawn.easy_async_with_shell('cp ' .. path .. ' ' .. perm_dir, function()
         naughty.notification({
            icon    = beautiful.notification_default,
            title   = 'Screenshot',
            message = 'Saved to ' .. perm_dir,
            actions = { ok }
         })
      end)
   end)

   discard:connect_signal('invoked', function()
      awful.spawn.easy_async_with_shell('rm ' .. path, function()
         naughty.notification({
            icon    = beautiful.notification_cancel,
            title   = 'Screenshot',
            message = 'Temporary file removed!',
            actions = { ok }
         })
      end)
   end)

   -- Check whether the screenshot was taken or not.
   local file = io.open(path)
   if file ~= nil then
      -- If it exists:
      io.close(file)
      naughty.notification({
         icon    = path,
         title   = 'Screenshot',
         message = 'Copied to clipboard!',
         actions = { save, discard }
      })
   else
      -- If it doesn't:
      naughty.notification({
         icon    = beautiful.notification_cancel,
         title   = 'Screenshot',
         message = 'Cancelled!',
         actions = { ok }
      })
   end
end

-- Takes a screenshot and puts it in `/tmp`, then copies it to system clipboard
-- and notifies about the result.
local function take_screenshot(cmd)
   local tmp = '/tmp/ss-' .. os.date('%Y%m%d-%H%M%S') .. '.png'
   awful.spawn.easy_async_with_shell(cmd .. ' ' .. tmp, function()
      awful.spawn.with_shell('xclip -selection clip -t image/png -i ' .. tmp)
      send_notif(tmp)
   end)
end

return {
   screen    = function() take_screenshot('maim')          end,
   selection = function() take_screenshot('maim -s')       end,
   delayed   = function() take_screenshot('sleep 3; maim') end
}
