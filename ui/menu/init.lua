local awful     = require('awful')
local beautiful = require('beautiful')
local wibox     = require('wibox')

local hotkeys = require('awful.hotkeys_popup')
local dpi = beautiful.xresources.apply_dpi

local apps  = require('config.apps')
local user  = require('config.user')
local color = require(beautiful.colorscheme)

--- Menu
local menu = {}
local section = {}

section.awesome = {
   { 'Hotkeys',       function() hotkeys.show_help(nil, awful.screen.focused()) end },
   { 'Documentation', apps.browser .. ' https://awesomewm.org/apidoc' },
   { 'Configuration', apps.editor_cmd .. ' ' .. awesome.conffile },
   { 'Reload',        awesome.restart }
}

section.power = {
   { 'Log off',  function() awesome.quit() end },
   { 'Suspend',  function() os.execute(user.suspend_cmd) end },
   { 'Reboot',   function() os.execute(user.reboot_cmd) end },
   { 'Shutdown', function() os.execute(user.shutdown_cmd) end }
}

-- Create a main menu.
menu.main = awful.menu({
   theme = {
      font   = beautiful.font_bitm .. dpi(9),
      width  = dpi(172),
      height = dpi(32),
      bg_normal = color.bg0,
      bg_focus  = color.bg1,
      border_width = dpi(1),
      border_color = color.bg3
   },
   items = {
      { 'Terminal', apps.terminal },
      { 'Editor',   apps.editor },
      { 'Browser',  apps.browser },
      { 'Awesome',  section.awesome },
      { 'Power',    section.power }
   }
})

-- Add margins.
menu.main.wibox:set_widget(wibox.widget({
   widget  = wibox.container.margin,
   margins = dpi(12),
   {
      widget = wibox.container.background,
      menu.main.wibox.widget
   }
}))
-- Repeat for submenus.
awful.menu.old_new = awful.menu.new
function awful.menu.new(...)
   local submenu    = awful.menu.old_new(...)
   submenu.wibox.bg = color.bg0
   submenu.wibox.border_width = dpi(1)
   submenu.wibox.border_color = color.bg3
   submenu.wibox:set_widget(wibox.widget({
      widget = wibox.container.background,
      bg     = color.bg0,
      {
         widget  = wibox.container.margin,
         margins = dpi(12),
         {
            widget = wibox.container.background,
            submenu.wibox.widget
         }
      }
   }))
   return submenu
end

return menu
