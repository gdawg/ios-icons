#!/usr/bin/env lua

N = 24 -- iphone 6/6s

if #arg > 0 then
  local a = arg[1]
  if a[1] == "-" then
    print("shift icons leftwards until there is N per page.")
    print("options: [N]")
    os.exit(1)
  end

  N = tonumber(a)
end

ios = require("ios-icons")
conn = ios.connect()
icons = conn:icons()

function fillpage(icons, n, p)
  local page = icons[n]
  n2 = n + 1
  local stealfrom = icons[n2]
  if stealfrom == nil then 
    print("final page " .. n .. " has " .. #page .. " icons")
    return 
  end

  while #page < N do
    print('moving icon from ' .. n2 .. ' to ' .. (n))
    table.insert(page, table.remove(stealfrom))

    if #stealfrom == 0 then
      for j=n2,#icons do
        icons[j] = icons[j+1]
      end
      stealfrom = icons[n2]
    end
  end

  print("page " .. n .. " has " .. #page .. " icons")

  icons[n] = page
  icons[n2] = stealfrom
  return icons
end


for i=2,14 do
  icons = fillpage(icons, i)
  if not icons then return end
  conn:set_icons(icons)
end
