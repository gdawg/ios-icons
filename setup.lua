ios = require "ios-icons"
inspect = require "inspect"

conn = ios.connect()
icons = conn:icons()
dock = icons:dock()

-- swap a and b
function swap(a,b)
	icons:swap(a,b)
	conn:set_icons(icons)
end

-- pretty printing
function pp(x)
  print(inspect.inspect(x))
end
