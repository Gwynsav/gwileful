local tym   = require('tym')
local theme = dofile(tym.get_theme_path())

tym.set_config({
  -- Basics 
  ---------
  shell  = 'hilbish',
  font   = 'Fairfax 9',
  silent = true,

  -- Cursor
  ---------
  cursor_shape      = 'underline',
  cursor_blink_mode = 'on',
  autohide          = true,

  -- Bling
  --------
  padding_horizontal = 24,
  padding_vertical   = 24,
})

--- Set/modify binds.
tym.set_keymap('<Ctrl>0', function()
  for id in pairs(tym.get_ids()) do
    tym.signal(id, 'hook', {'reload'})
  end
end)

--- Modifies behaviors.
-- Makes it so scrolling works on mouse wheel.
tym.set_hook('scroll', function(_, dy)
	local s;
   if tym.check_mod_state('<Ctrl>') then
		if dy > 0 then
			s = tym.get('scale') - 10
    	else
      	s = tym.get('scale') + 10
    	end
    	tym.set('scale', s)
    	return true
	end
end)

-- Makes all instances of tym reload.
tym.set_hook('signal', function(command)
  if command == 'reload' then
    tym.reload()
    return
  end
end)
