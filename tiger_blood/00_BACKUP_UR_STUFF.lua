ios = require "ios-icons"
conn = ios.connect()

function save_backup()
	path = "icons_" .. os.date('%Y%m%d.%H%M') .. ".plist"
	conn:icons():save_plist(path) 
	io.write("if you don't see any errors above your ")
	io.write("icon order is stored in " .. path)
end

-- icons = ios.load_plist("icons_20141204.2056.plist")
-- conn:set_icons(icons)

save_backup()
-- see above for restore

conn:disconnect()
