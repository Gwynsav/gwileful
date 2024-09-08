local require = require

local awful = require('awful')
local dpi   = require('beautiful').xresources.apply_dpi

local apps    = require('config.apps')
local scratch = require('module.bling').module.scratchpad

local s = awful.screen.focused()
local h = dpi(400)
local w = dpi(600)

return scratch({
   -- `autoclose` is the buggiest shit on earth.
   command   = apps.terminal .. ' --role="musicpad" -e ncmpcpp',
   rule      = { role = 'musicpad' },
   sticky    = true,
   floating  = true,
   geometry  = {
      height = h, width = w,
      x = (s.geometry.width - w) / 2,
      y = (s.geometry.height - h) / 2 + s.bar.height
   }
})
