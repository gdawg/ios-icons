ios = require "ios-icons"
fn = require "ios-icons.fn"

function readfrom_path(path)
  local top = {}
  fd = io.open(path)
  while true do txt = fd:read("*l")
    if not txt then break end
    table.insert(top, txt)
  end
  fd:close()
  return top
end

function add_to_front(a, b)
  for i=1,#b do table.insert(a, i, b[i]) end
end

function arrange_icons(conn)
  local icons = conn:icons()
  local flat = icons:flatten()
  flat.add_to_front = add_to_front
  local ordered = {}

  -- add from txt file first
  for _,name in ipairs(readfrom_path("top_apps.txt")) do
    table.insert(ordered, icons:find(name))
  end

  -- convenience wrapper: add icons matching cond(icon) next
  add_next = function(cond) for _,i in ipairs(fn.select(flat, cond )) 
      do table.insert(ordered, i) 
    end
  end

  add_next(function(i) return i.id:find("mad.dog") end)
  add_next(function(i) return string.find(i.id .. i.name, "camera") end)
  add_next(function(i) return string.find(i.id .. i.name, "photo") end)

  table.sort(flat)
  flat:add_to_front(ordered)
  conn:set_icons(icons.reshape(flat))
end


arrange_icons(ios.connect())

