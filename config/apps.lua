-- This is used later as the default terminal and editor to run.
local apps = {}

apps.terminal     = os.getenv('TERM') or 'xterm'
apps.terminal_cmd = apps.terminal .. ' -e '

apps.editor     = os.getenv('EDITOR') or 'vim'
apps.editor_cmd = apps.terminal_cmd .. apps.editor

apps.browser    = 'firefox'

-- Set the terminal for the menubar.
require('menubar').utils.terminal = apps.terminal

return apps
