-- Logic based largely (carbon copied, for the most part) on Stardust-kyun's launcher.
-- I removed mouse support :P
-- https://github.com/Stardust-kyun/dotfiles/blob/126b2df5edbec8044cbdbf13fb261f935311f6fe/home/.config/awesome/theme/launcher.lua

local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi
local gio = require('lgi').Gio

local user  = require('config.user')
local color = require(beautiful.colorscheme)
local height, width, margin = 220, 540, 6
local entry_max = 12
local screen = awful.screen.focused()

local launcher = wibox({
   visible = false,
   ontop   = true,
   width   = dpi(width),
   height  = dpi(height),
   x       = dpi((screen.geometry.width - width) / 2),
   y       = dpi(screen.geometry.height - height - margin),
   bg      = color.bg0,
   border_width = dpi(1),
   border_color = color.bg3
})

--- Widgets
-----------
local _W = {}
_W.prompt = wibox.widget.textbox('Search')
_W.entries = wibox.widget({
   layout  = wibox.layout.grid,
   spacing = dpi(8),
   expand  = true,
   column_count = 3,
   minimum_row_height = dpi(29),
   homogenous = false
})

launcher:setup({
   layout = wibox.layout.stack,
   {
      widget = wibox.widget.imagebox,
      image  = gears.surface.crop_surface({
         ratio   = width / height,
         surface = gears.surface.load_uncached(user.wallpaper)
      })
   },
   {
      widget = wibox.container.background,
      bg = {
         type  = 'linear',
         from  = { 0, 0 },
         to    = { 0, dpi(height) },
         stops = {
            { 0, color.bg0 .. 'A0' }, { 0.25, color.bg0 .. 'D0' },
            { 0.4, color.bg0 .. 'F0' }, { 0.55, color.bg0 }, { 1, color.bg0 }
         }
      },
      {
         widget  = wibox.container.margin,
         margins = dpi(16),
         {
            layout  = wibox.layout.fixed.vertical,
            spacing = dpi(16),
            {
               layout = wibox.layout.align.horizontal,
               nil, nil,
               {
                  layout = wibox.layout.fixed.vertical,
                  {
                     widget = wibox.container.background,
                     bg     = color.bg0,
                     {
                        widget  = wibox.container.margin,
                        margins = dpi(8),
                        forced_height = dpi(28),
                        _W.prompt
                     }
                  },
                  {
                     widget = wibox.container.background,
                     bg     = color.bg2,
                     forced_height = dpi(1)
                  }
               }
            },
            _W.entries
         }
      }
   }
})

--- App related
---------------
local _A = {}

-- Gets all entries.
function _A.gen()
   local entry_list = {}
   for _, entry in ipairs(gio.AppInfo.get_all()) do
      if entry:should_show() then
         local name =
            entry:get_name():gsub("&", "&amp;"):gsub("<", "&lt;"):gsub("'", "&#39;")
         table.insert(entry_list, { name = name, appinfo = entry })
      end
   end
   return entry_list
end

-- Reduces shown entries to those matching the user's input, sorted and merged into one
-- table.
function _A.filter(cmd)
   _A.filtered = {}
   _A.reg_filtered = {}

   -- Filter entries matching `cmd` (user's input).
   for _, entry in ipairs(_A.unfiltered) do
      if entry.name:lower():sub(1, cmd:len()) == cmd:lower() then
         table.insert(_A.filtered, entry)
      elseif entry.name:lower():match(cmd:lower()) then
         table.insert(_A.reg_filtered, entry)
      end
   end
   -- Sort remaining entries.
   table.sort(_A.filtered, function(a, b) return a.name:lower() < b.name:lower() end)
   table.sort(_A.reg_filtered, function(a, b) return a.name:lower() < b.name:lower() end)
   -- Merge entries.
   for i = 1, #_A.reg_filtered do
      _A.filtered[#_A.filtered + 1] = _A.reg_filtered[i]
   end
   -- Clear entries.
   _W.entries:reset()
   _A.entry_index, _A.start_index = 1, 1

   -- Add filtered entries.
   for i, entry in ipairs(_A.filtered) do
      local widget = wibox.widget({
         widget = wibox.container.background,
         bg     = color.bg1,
         fg     = color.fg0,
         border_width = dpi(1),
         border_color = color.bg1,
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(6), bottom = dpi(6),
               left = dpi(12), right = dpi(12)
            },
            wibox.widget.textbox(entry.name)
         }
      })

      widget.visible = (_A.start_index <= i and i <= _A.start_index + entry_max - 1)
      _W.entries:add(widget)
      if i == _A.entry_index then
         widget.fg = color.accent
         widget.border_color = color.bg3
      end
   end

   collectgarbage('collect')
end

function _A.open()
   -- Reset everything.
   _A.start_index, _A.entry_index = 1, 1
   -- Gets all entries.
   _A.unfiltered = _A.gen()
   _A.filter('')

   -- Populates prompt and makes it responsive.
   awful.prompt.run({
      prompt  = 'Searching: ',
      textbox = _W.prompt,
      -- Upon modifying the contents of the prompt.
      changed_callback = function(cmd)
         _A.filter(cmd)
      end,
      -- Upon pressing enter.
      exe_callback = function(cmd)
         local entry = _A.filtered[_A.entry_index]
         if entry then
            entry.appinfo:launch()
         else
            awful.spawn.with_shell(cmd)
         end
      end,
      -- When all else is done.
      done_callback = function()
         launcher.visible = false
      end
   })
end

function launcher:open()
   launcher.visible = not launcher.visible

   if launcher.visible then
      _A.open()
   else
      awful.keygrabber.stop()
   end
end

return launcher
