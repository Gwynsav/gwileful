local awful     = require('awful')
local beautiful = require('beautiful')
local gears     = require('gears')
local naughty   = require('naughty')
local wibox     = require('wibox')

local dpi = beautiful.xresources.apply_dpi

local helpers = require('helpers')
local color   = require(beautiful.colorscheme)

local _N = {}

function _N.title(n)
   return wibox.widget({
      widget = wibox.container.scroll.horizontal,
      {
         widget = wibox.widget.textbox,
         markup = n.title or 'Notification'
      }
   })
end

function _N.body(n)
   return wibox.widget({
      widget = wibox.container.scroll.vertical,
      {
         widget = wibox.widget.textbox,
         markup = n.body
      }
   })
end

function _N.icon(n)
   return wibox.widget({
      widget = wibox.widget.imagebox,
      image  = n.icon and helpers.crop_surface(1, gears.surface.load_uncached(n.icon))
         or beautiful.awesome_icon,
      buttons = { awful.button(nil, 1, function() n:destroy() end) },
      horizontal_fit_policy = 'fit',
      vertical_fit_policy   = 'fit'
   })
end

function _N.timeout(n)
   return wibox.widget({
      widget    = wibox.container.arcchart,
      min_value = 0,
      max_value = 100,
      value     = 0,
      thickness = dpi(2),
      paddings  = dpi(2),
      colors    = { color.accent },
      _N.icon(n)
   })
end

return function(n)
   return naughty.layout.box({
      notification = n,
      position     = 'top_left',
      cursor       = 'hand2',
      border_width = 0,
      buttons      = nil,
      widget_template = {
         widget   = wibox.container.contraint,
         strategy = 'max',
         height   = dpi(320),
         {
            widget   = wibox.container.contraint,
            strategy = 'exact',
            width    = dpi(320),
            {
               widget = wibox.container.background,
               bg     = color.bg1,
               {
                  layout = wibox.layout.fixed.horizontal,
                  {
                     widget  = wibox.container.margin,
                     margins = dpi(8),
                     {
                        widget   = wibox.container.contraint,
                        strategy = 'max',
                        height   = dpi(48),
                        width    = dpi(48),
                        _N.timeout(n)
                     }
                  },
                  {
                     widget = wibox.container.background,
                     bg     = color.bg0,
                     {
                        widget  = wibox.container.margin,
                        margins = dpi(8),
                        {
                           widget = wibox.container.place,
                           valign = 'center',
                           {
                              layout = wibox.layout.fixed.vertical,
                              _N.title(n),
                              _N.body(n)
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   })
end
