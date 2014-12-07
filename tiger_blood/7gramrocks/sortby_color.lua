ios = require "ios-icons.tiger-blood"

function by_color(iconlist)
    local res = {}
    for k,icon in pairs(iconlist) do
        local c = "unknown"
        if icon.image then c = icon.image.color() end
        if not res[c] then res[c] = {} end
        table.insert(res[c], icon)
    end
    return res
end

print("sorting by color")
conn = ios.connect() 
icons = conn:icons()

flat = icons:flatten()
cgroups = by_color(flat)
final = {}
for _,cg in pairs(cgroups) do
    for _,i in pairs(cg) do
        table.insert(final, i)
    end
end

shaped = icons.reshape(final)
conn:set_icons(shaped)
conn:disconnect()

print("done")




