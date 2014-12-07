ios = require "ios-icons"
conn = ios.connect()
icons = conn:icons()
dock = icons:dock()

function swap(a,b)
	icons:swap(a,b)
	conn:set_icons(icons)
end
