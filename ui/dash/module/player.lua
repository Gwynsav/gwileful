local require, math, string, collectgarbage = require, math, string, collectgarbage

local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi   = beautiful.xresources.apply_dpi
local pctl  = require('signal.system.playerctl')

local widget = require('widget')
local color  = require(beautiful.colorscheme)
local icons  = require('theme.icons')
local player = require('ui.scratch').music
local user   = require('config.user')

return function()
   -- The art is a bit special.
   local song_art = wibox.widget.imagebox()
   if not user.lite or user.lite == nil then
      song_art.image = gears.surface.crop_surface({
         ratio   = 3,
         surface = beautiful.wallpaper
      })
   end

   local function button(icon, action)
      local w = widget.textbox.colored({
         text = icon,
         font = icons.font .. icons.size
      })
      w.buttons = { awful.button({}, 1, action) }
      w:connect_signal('mouse::enter', function(self)
         self.color = color.bccent
      end)
      w:connect_signal('mouse::leave', function(self)
         self.color = color.fg0
      end)
      return w
   end

   local song_icon   = button(icons['music'], function() player:turn_on() end)
   local song_status = widget.textbox.colored({
      text  = 'Paused',
      color = color.fg1
   })
   local song_player = widget.textbox.colored({
      text  = 'Source Unknown',
      color = color.fg1,
      align = 'right'
   })
   local song_title  = widget.textbox.scrolling({
      text  = 'Nothing Playing',
      font  = beautiful.font_mono .. beautiful.bitm_size
   })
   local song_artist = widget.textbox.scrolling({
      text  = 'by Unknown',
      font  = beautiful.font_mono .. beautiful.bitm_size,
      color = color.fg1
   })
   local song_album  = widget.textbox.scrolling({
      text  = 'No album',
      font  = beautiful.font_mono .. beautiful.bitm_size,
      color = color.fg2
   })

   local prog_text   = widget.textbox.colored({
      text  = '00:00 / 00:00',
      font  = beautiful.font,
      color = color.fg1
   })
   local prog_slider = wibox.widget({
      widget  = wibox.widget.slider,
      minimum = 0,
      maximum = 100,
      value   = 0,
      bar_color        = color.bg1,
      bar_active_color = color.bg3
   })

   local play_pause = button(icons['music_play'],  function() pctl:play_pause() end)
   local back = button(icons['music_previous'], function() pctl:previous() end)
   local forward = button(icons['music_next'], function() pctl:next() end)
   local loop = button(icons['music_loop'], function() pctl:cycle_loop_status() end)
   local loop_text = widget.textbox.colored({ text = 'None' })
   local shuffle = button(icons['music_shuffle'], function() pctl:cycle_shuffle() end)
   local last_shuffle = false
   shuffle:connect_signal('mouse::leave', function(self)
      self.color = last_shuffle and color.accent or color.fg0
   end)

   local w = wibox.widget({
      layout = wibox.layout.stack,
      song_art,
      {
         widget = wibox.container.background,
         bg = {
            type  = 'linear',
            from  = { 0, 0 },
            to    = { dpi(360), 0 },
            stops = {
               { 0, color.bg0 .. 'EF' }, { 0.45, color.bg0 .. 'EF' },
               { 0.73, color.bg0 .. 'CC' }, { 1, color.bg0 .. 'A0' }
            }
         },
         border_width = dpi(1),
         border_color = color.bg3,
         {
            layout = wibox.layout.align.vertical,
            {
               widget  = wibox.container.margin,
               margins = {
                  top = dpi(16), bottom = dpi(14),
                  left = dpi(16), right = dpi(16)
               },
               {
                  layout  = wibox.layout.fixed.vertical,
                  spacing = dpi(8),
                  {
                     layout = wibox.layout.align.horizontal,
                     {
                        layout  = wibox.layout.fixed.horizontal,
                        spacing = dpi(6),
                        song_icon,
                        song_status
                     },
                     nil,
                     song_player
                  },
                  {
                     layout = wibox.layout.fixed.vertical,
                     song_title,
                     song_artist,
                     song_album
                  },
                  {
                     layout = wibox.layout.align.horizontal,
                     prog_text,
                     nil,
                     {
                        layout  = wibox.layout.fixed.horizontal,
                        spacing = dpi(4),
                        back,
                        play_pause,
                        forward,
                        {
                           widget  = wibox.container.margin,
                           margins = { left = dpi(4), right = dpi(4) },
                           {
                              layout = wibox.layout.fixed.horizontal,
                              spacing = dpi(6),
                              loop,
                              loop_text
                           }
                        },
                        shuffle
                     }
                  }
               }
            },
            nil,
            {
               layout = wibox.layout.fixed.vertical,
               {
                  widget = wibox.container.background,
                  bg = color.bg3,
                  forced_height = dpi(1)
               },
               {
                  widget   = wibox.container.constraint,
                  strategy = 'exact',
                  height   = dpi(4),
                  prog_slider
               }
            }
         }
      }
   })

   -- Why not just use the `new` variable that the signal exposes? Because the first song
   -- that comes never counts as new, and so using the `new` variable results in the first
   -- song upon AwesomeWM reload not updating the widget.
   local last_poll = {
      title  = nil,
      artist = nil,
      prog   = 0
   }
   pctl:connect_signal('metadata', function(_, title, artist, cover, album, _, source)
      -- Whenever a new song comes through:
      if title ~= last_poll.title or artist ~= last_poll.artist then
         -- Update widget info.
         song_title.text  = gears.string.xml_unescape(title or 'Unknown')
         song_artist.text = 'by ' .. (gears.string.xml_unescape(artist or 'Unknown'))
         song_album.text  = 'on ' .. (gears.string.xml_unescape(album or 'Unknown'))
         song_player.text = 'via ' .. source
         -- Update image only if desired.
         if not user.lite or user.lite == nil then
            song_art.image   = gears.surface.crop_surface({
               ratio   = 3,
               surface = gears.surface.load_uncached(cover or beautiful.wallpaper)
            })
         end

         -- Update last poll info.
         last_poll.title  = title
         last_poll.artist = artist
         last_poll.player = source

         -- Manually call Lua's gc to get rid of the old album art and prevent memory
         -- usage from stacking up.
         collectgarbage('collect')
      end
   end)

   pctl:connect_signal('position', function(_, prog, len, _)
      prog_slider.maximum = len
      prog_slider.value   = prog
      prog_text.text      = string.format('%02d:%02d', math.floor(prog / 60), prog % 60)
         .. ' / ' .. string.format('%02d:%02d', math.floor(len / 60), len % 60)
   end)

   pctl:connect_signal('playback_status', function(_, playing, _)
      if playing then
         prog_slider.bar_active_color = color.bg4
         song_status.text = 'Playing'
         play_pause.text = icons['music_pause']
      else
         prog_slider.bar_active_color = color.bg3
         song_status.text = 'Paused'
         play_pause.text = icons['music_play']
      end
   end)

   pctl:connect_signal('loop_status', function(_, loop_status, _)
      loop_text.text = loop_status:gsub('^%l', string.upper)
   end)

   pctl:connect_signal('shuffle', function(_, shuff, _)
      shuffle.color = shuff and color.accent or color.fg0
      last_shuffle = shuff
   end)

   -- Prevent overwriting of song progress when not using the bar to seek.
   -- Expecting a seek to differ by 4 seconds from the previous time seems to do the
   -- trick.
   local prog_hover = false
   prog_slider:connect_signal('mouse::enter', function()
      prog_hover = true
   end)
   prog_slider:connect_signal('mouse::leave', function()
      prog_hover = false
   end)
   prog_slider:connect_signal('property::value', function(_, new)
      if prog_hover and (new > last_poll.prog + 4 or new < last_poll.prog - 4) then
         pctl:set_position(new)
      end
      last_poll.prog = new
   end)

   return w
end
