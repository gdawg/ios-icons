local ios = require "ios-icons.tiger-blood"
local fn = require "ios-icons.fn"

inspect = require "inspect"
function pp(x,h) print(inspect(x)) return x end

conn,icons = ios.gimme()

print("caching into " .. icons:itunes_cache().cachedir)

-- param is optional but adviseable
function fetch_data()
    demo_fetch_idx = 0
    icons:add_itunes_data(function(icon)
        demo_fetch_idx = demo_fetch_idx + 1
        if demo_fetch_idx % 5 == 0 then
            io.write(".")
            io.flush()
        end
    end)
end

print("downloading data")
fetch_data()

prefer_breakdown = { 
    { "Frequent", "Infrequent", "Unrestricted Web Access" },
    { "Intense Profanity or Crude Humor", "Intense Sexual Content or Nudity",
      "Mild Profanity or Crude Humor", "Mild Sexual Content and Nudity",
      "Intense Mature", "Intense Cartoon or Fantasy Violence",
      "Mild Realistic Violence", "Intense Horror",
      "Mild Cartoon or Fantasy Violence",
      "Mild Alcohol, Tobacco, or Drug Use or References",
      "Mild Mature", "Mild Horror", "Mild Simulated Gambling",
      "Mild Medical", "Intense Medical" },
    { "Suggestive Themes", "Fear Themes", "Treatment Information" },
}

function alloc_points()
    local points = {}
    for i,row in pairs(prefer_breakdown) do
        for j,term in pairs(row) do points[term] = j end
        for t,p in pairs(points) do points[t] = 8 * p end
    end
    return points
end

points_for_terms = alloc_points()

function split(adv)
    local r = {}
    for x in string.gmatch(adv, "([^/]*)") do table.insert(r,x) end
    return fn.select(r, function(s) 
        return #s > 0
    end)
end

function points_for_advisory(adv)
    local points = 0
    if not adv or #adv < 1 then return 0 end
    for _,adv_n in ipairs(adv) do
        for _,v in pairs(split(adv_n)) do
            points = points + points_for_terms[v]
        end
    end
    return points
end

flat = icons:flatten()
for _,i in ipairs(flat) do
    if not i.data then i.data = {} end
    i.points = points_for_advisory(i.data.advisories)
end

io.write("\n")
print("sort by crudeness / profanity in progress")
table.sort(flat, function(a, b)
    return a.points > b.points    
end)

conn:set_icons(icons.reshape(flat))

conn:disconnect()