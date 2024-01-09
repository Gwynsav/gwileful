-- Credits to Aproxia for the timeout animation logic.
-- https://github.com/Aproxia-dev

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
      step_function = wibox.container.scroll.step_functions
         .waiting_nonlinear_back_and_forth,
      speed = 50,
      {
         widget = wibox.widget.textbox,
         font   = beautiful.font_sans .. dpi(9),
         markup = '<i><b>' .. (n.title or 'Notification') .. '</b></i>'
      }
   })
end

function _N.body(n)
   return wibox.widget({
      widget = wibox.container.background,
      fg     = color.fg0 .. 'cc',
      {
         widget = wibox.container.scroll.vertical,
         {
            widget = wibox.widget.textbox,
            font   = beautiful.font_sans .. dpi(9),
            markup = n.message
         }
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
      thickness = dpi(3),
      paddings  = dpi(4),
      bg        = color.bg1,
      colors    = { color.fg1 },
      _N.icon(n)
   })
end

function _N.actions(n)
   return wibox.widget({
      widget       = naughty.list.actions,
      notification = n,
      base_layout  = wibox.widget({
         layout  = wibox.layout.flex.horizontal,
         spacing = dpi(2)
      }),
      style = {
         underline_normal   = false,
         underline_selected = false,
         bg_normal          = color.bg1
      },
      widget_template = {
         widget = wibox.container.background,
         bg     = color.bg4 .. '20',
         {
            widget  = wibox.container.margin,
            margins = dpi(3),
            {
               widget = wibox.container.place,
               halign = 'center',
               {
                  widget = wibox.widget.textbox,
                  font   = beautiful.font_bitm .. dpi(9),
                  id     = 'text_role'
               }
            }
         }
      }
   })
end

return function(n)
   -- Store original timeout and set it to an unreachable number.
   local timeout = n.timeout
   -- Using `math.huge` here breaks naughty :P.
   n.timeout = 999999
   local timeout_bar = _N.timeout(n)

   -- Sections, divided into blocks because to avoid YandereDev levels of indentation.
   -- Contains the timeout bar and icon.
   local icon_block = wibox.widget({
      widget  = wibox.container.margin,
      margins = dpi(12),
      {
         widget   = wibox.container.constraint,
         strategy = 'max',
         height   = dpi(64),
         width    = dpi(64),
         timeout_bar
      }
   })

   -- Contains the title, body, and action buttons.
   local text_block = wibox.widget({
      widget  = wibox.container.margin,
      margins = dpi(2),
      {
         widget   = wibox.container.constraint,
         strategy = 'min',
         width    = dpi(120),
         {
            widget = wibox.container.background,
            bg     = color.bg1,
            {
               widget  = wibox.container.margin,
               margins = dpi(18),
               {
                  widget = wibox.container.place,
                  halign = 'left',
                  valign = 'center',
                  {
                     layout  = wibox.layout.fixed.vertical,
                     spacing = dpi(4),
                     _N.title(n),
                     _N.body(n),
                     {
                        -- Add extra spacing to avoid having it look weird.
                        widget  = wibox.container.margin,
                        margins = { top = dpi(4) },
                        -- This, however, makes you have to hide the spacing itself.
                        visible = #n.actions > 0,
                        _N.actions(n)
                     }
                  }
               }
            }
         }
      }
   })

   local layout = naughty.layout.box({
      notification = n,
      -- position     = 'top_left',
      cursor       = 'hand2',
      border_width = 0,
      widget_template = {
         widget   = wibox.container.constraint,
         strategy = 'max',
         height   = dpi(320),
         {
            widget   = wibox.container.constraint,
            strategy = 'max',
            width    = dpi(360),
            {
               widget = wibox.container.background,
               bg     = color.bg0,
               {
                  layout = wibox.layout.fixed.horizontal,
                  icon_block,
                  text_block
               }
            }
         }
      }
   })
   -- For some reason, doing this inside the `layout` declaration just doesn't work.
   -- You have to do it imperatively or it'll literally just get ignored.
   layout.buttons = {}

   -- Create an animation for the timeout.
   local anim = require('module.rubato').timed({
      intro      = 0,
      duration   = timeout,
      subscribed = function(pos, time)
         timeout_bar.value = pos
         if time == timeout then
            n:destroy()
            collectgarbage('collect')
            collectgarbage('collect')
         end
      end
   })
   -- Stop the timeout on notification hover.
   layout:connect_signal('mouse::enter', function() anim.pause = true  end)
   layout:connect_signal('mouse::leave', function() anim.pause = false end)
   anim.target = 100

   return layout
end
