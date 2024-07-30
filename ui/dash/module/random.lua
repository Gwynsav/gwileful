local wibox = require('wibox')

local messages = {
   'This is the world of the recycled vessel, created to avoid the destruction of all.',
   'The Black Scrawl. A lost destiny. A white book. A false truth.',
   'Soldiers of salt calling forth white death. They are Legion, those who plunged the' ..
   ' world into darkness.',
   'The dragon\'s corpse brought death to the world, delivering unto it the power of ' ..
   'magic.',
   'The black sickness stains the future. They journey to return to soulless vessels.',
   'The apocalypse divided the world in two: one that knows not day, and one which has' ..
   ' never seen night.',
   'Black and White. Thirteen pacts. The vessels\' forms waver as they cross time and ' ..
   'space.',
   'The song of man has been drowned out. In its place, the scream of something inhuman.',
   'The sky falls with the dragon. The world ends this day.',
   'The puppet priest collects the accursed prayers and polishes the vessel.',
   'So long as this memory exists -so long as mankind has hope- a bloody battle will ' ..
   'be waged over the holy domain of the body.',
   'Foolish human. Foolish human. Foolish human.\nFoolish vessel.',
   'All is paid. All is sacrifice.',
   'Do not bring back the light. Do not bring back the vessel. Do not bring back the ' ..
   'future. Do not bring it back.',
   'Every beam of light is an invitation to death.'
}

return function()
   return wibox.widget({
      widget = wibox.widget.textbox,
      text   = messages[math.random(#messages)],
      halign = 'center'
   })
end
