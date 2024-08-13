local beautiful = require('beautiful')
local gears     = require('gears')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local color  = require(beautiful.colorscheme)
local pctl   = require('signal.system.playerctl')
local helper = require('helpers')
local icons  = require('theme.icons')

local width, height, timeout = 300, 100, 3

return function(s)
   local _W = {}

   _W.cover = wibox.widget.imagebox()
   _W.icon = helper.ctext({
      text  = icons['music'],
      font  = icons.font .. icons.size,
      color = color.fg1
   })
   _W.player = helper.ctext({
      text  = 'N/A',
      color = color.fg1,
      align = 'right'
   })
   _W.title = helper.stext({
      text = 'Nothing Playing'
   })
   _W.artist = helper.stext({
      text  = 'by Unknown',
      color = color.fg1
   })
   _W.album = helper.stext({
      text  = 'on N/A',
      color = color.fg2
   })
   _W.progress = helper.ctext({
      text  = '00:00 / 00:00',
      color = color.fg1
   })
   _W.status = wibox.widget({
      widget = wibox.container.constraint,
      {
         layout  = wibox.layout.fixed.horizontal,
         spacing = dpi(8),
         {
            widget = helper.ctext({
               text  = icons['music_pause'],
               font  = icons.font .. icons.size,
               align = 'right'
            }),
            id = 'icon'
         },
         {
            widget = helper.ctext({
               text  = 'Paused',
               align = 'right'
            }),
            id = 'text'
         }
      },
      set_icon = function(self, icon)
         self:get_children_by_id('icon')[1].text = icon
      end,
      set_status = function(self, text)
         self:get_children_by_id('text')[1].text = text
      end
   })
   _W.volume = wibox.widget({
      widget = wibox.widget.progressbar,
      background_color = color.bg1,
      color = color.fg0,
      max_value = 100,
   })
   _W.volume_level = helper.ctext({
      text  = icons['audio_muted'],
      font  = icons.font .. icons.size,
      align = 'center'
   })

   local osd = wibox({
      x = (s.geometry.width - width) / 2,
      y = s.bar.height + beautiful.useless_gap,
      height  = height,
      width   = width,
      screen  = s,
      bg      = color.bg0,
      ontop   = true,
      visible = false,
      border_width = dpi(1),
      border_color = color.bg3,
      widget = {
         layout = wibox.layout.fixed.horizontal,
         {
            layout = wibox.layout.stack,
            _W.cover,
            {
               widget = wibox.container.background,
               bg     = {
                  type  = 'linear',
                  from  = { 0, 0 },
                  to    = { dpi(width), 0 },
                  stops = {
                     { 0, color.bg0 .. 'EF' }, { 0.45, color.bg0 .. 'EF' },
                     { 0.73, color.bg0 .. 'CC' }, { 1, color.bg0 .. 'A0' }
                  }
               },
               {
                  widget  = wibox.container.margin,
                  margins = dpi(12),
                  {
                     layout = wibox.layout.align.vertical,
                     expand = 'none',
                     {
                        layout = wibox.layout.align.horizontal,
                        _W.icon, nil, _W.player
                     },
                     {
                        layout = wibox.layout.fixed.vertical,
                        _W.title,
                        _W.artist,
                        _W.album
                     },
                     {
                        layout = wibox.layout.align.horizontal,
                        _W.progress, nil, _W.status
                     }
                  }
               }
            }
         },
         {
            widget = wibox.container.background,
            bg     = color.bg3,
            forced_width = dpi(1)
         },
         {
            widget  = wibox.container.margin,
            margins = {
               top = dpi(12), bottom = dpi(12),
               left = dpi(6), right = dpi(6)
            },
            {
               layout  = wibox.layout.fixed.vertical,
               spacing = dpi(8),
               _W.volume_level,
               {
                  widget  = wibox.container.margin,
                  margins = {
                     left = dpi(4), right = dpi(4)
                  },
                  {
                     widget = wibox.container.rotate,
                     direction = 'east',
                     _W.volume
                  }
               }
            }
         }
      }
   })

   local timer = gears.timer({
      timeout = timeout,
      single_shot = true,
      callback = function()
         osd.visible = false
      end
   })

   pctl:connect_signal('metadata', function(_, title, artist, cover, album, new, source)
      -- Update OSD.
      _W.player.text = (source or 'Unknown player')
      _W.title.text  = gears.string.xml_unescape(title) or 'Unknown'
      _W.artist.text = 'by ' .. (gears.string.xml_unescape(artist) or 'Unknown')
      _W.album.text  = 'on ' .. (gears.string.xml_unescape(album) or 'Unknown')
      _W.cover.image = gears.surface.crop_surface({
         surface = gears.surface.load_uncached(cover or beautiful.wallpaper),
         ratio   = (width - 24) / height
      })
      -- GC old album covers.
      collectgarbage('collect')

      -- Show the OSD when a new song comes through.
      if not new then return end
      -- Hide all other OSDs if visible.
      awesome.emit_signal('osd::new', osd)
      -- Reset timer.
      if timer.started then
         timer:again()
      else
         osd.visible = true
         timer:start()
      end
   end)

   pctl:connect_signal('playback_status', function(_, playing, _)
      -- Update OSD.
      if playing then
         _W.status.icon = icons['music_play']
         _W.status.status = 'Playing'
      else
         _W.status.icon = icons['music_pause']
         _W.status.status = 'Paused'
      end

      -- Hide all other OSDs if visible.
      awesome.emit_signal('osd::new', osd)
      -- Reset timer.
      if timer.started then
         timer:again()
      else
         osd.visible = true
         timer:start()
      end
   end)

   pctl:connect_signal('volume', function(_, volume, _)
      volume = volume * 100
      _W.volume.value = volume
      if volume == 0 then
         _W.volume_level.text = icons['audio_muted']
      elseif volume < 50 then
         _W.volume_level.text = icons['audio_decrease']
      else
         _W.volume_level.text = icons['audio_increase']
      end

      -- Hide all other OSDs if visible.
      awesome.emit_signal('osd::new', osd)
      -- Reset timer.
      if timer.started then
         timer:again()
      else
         osd.visible = true
         timer:start()
      end
   end)

   pctl:connect_signal('position', function(_, prog, len, _)
      _W.progress.text = string.format('%02d:%02d', math.floor(prog / 60), prog % 60)
         .. ' / ' .. string.format('%02d:%02d', math.floor(len / 60), len % 60)
   end)

   awesome.connect_signal('osd::new', function(new_osd)
      -- If the new osd is this one, do nothing.
      if new_osd == osd then return end
      -- Otherwise stop the timer and hide the osd if the timer is running.
      if timer.started then
         osd.visible = false
         timer:stop()
      end
   end)

   return osd
end
