local style = require('config.user').bar_style or 'horizontal'
return require(... .. '.' .. style)
