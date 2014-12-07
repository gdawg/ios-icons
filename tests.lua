-- BUSTED! - what's busted precious? http://olivinelabs.com/busted/
-- sidenote: i don't condone calling dude's prescious.

inspect = require "inspect"
function pp(x,h) print(inspect(x)) return x end
traceback = debug.traceback

describe("ios-iconlib", function()
  local ios, conn, icons
  local plist_path = "test.plist"

  setup(function()
    ios = require "ios-icons"
  end)

  it("loaded ok", function() 
    assert.not_nil(ios) 
    assert.not_function(ios) 
  end)

  it("connects and disconnects", function() 
    conn = ios.connect() 
    conn:disconnect()
  end)

  it("retrieves icons", function() 
    conn = ios.connect() 
    icons = conn:icons()

    assert.not_nil(icons)
    assert.is.table(icons)
    assert.is.truthy(#icons > 1)

    conn:disconnect()
  end)

  it("searches", function() 
    conn = ios.connect() 
    icons = conn:icons()

    assert.not_nil(icons:find("Messages"))
    assert.is.table(icons:find_all("App"))

    local many = icons:find_all(".*")
    assert.is.truthy(#many > 1)

    conn:disconnect()
  end)

  -- !WARNING! this bad boy is live. backup your
  -- shit if u are planning on enabling it.
  -- it("sets icons", function() 
  --   conn = ios.connect() 
  --   icons = conn:icons()
  --   conn:set_icons(icons)
  --   conn:disconnect()
  -- end)

  -- it("swaps icons", function() 
  --   conn = ios.connect() 
  --   icons = conn:icons()

  --   local one = icons[1][1]
  --   local two = icons[1][2]
  --   icons:swap(icons[1][1], icons[1][2])
  --   assert.same(icons[1][1], two)
  --   assert.same(icons[1][2], one)

  --   conn:disconnect()
  -- end)


  it("complains when disconnected", function() 
    conn = ios.connect() 
    icons = conn:icons()
    conn:disconnect()

    assert.has_error(function() conn:icons() end)
  end)

  it("saves to disk", function() 
    conn = ios.connect() 
    icons = conn:icons()

    icons:save_plist(plist_path)
    data = io.open(plist_path,"r"):read()

    conn:disconnect()
  end)

  it("loads from disk", function() 
    conn = ios.connect() 

    icons = conn:icons()
    old = ios.load_plist(plist_path)
    -- same number of pages
    assert.same(#icons, #old)
    -- same icons per page
    for i=1,#icons do
      assert.same(#icons[i], #old[i])
    end
    -- same icon names
    for i=1,#icons do
      for j=1,#icons[i] do
        assert.same(icons[i][j].name, old[i][j].name)
      end
    end

    os.remove(plist_path)
    conn:disconnect()
  end)


  it("provides image data", function()
    conn = ios.connect() 
    icons = conn:icons()

    icon = icons[1][1]
    assert.not_nil(icon.bundleIdentifier)
    assert.not_nil(conn:icon_image(icon))

    conn:disconnect()
  end)

end)


  


