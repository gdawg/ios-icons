local enabler = {
    ios = require "ios-icons",
    extras = {
        "ios-icons.itunes",
        "ios-icons.graphics",
        "ios-icons.animation",
    },
}

local function extra_modules()
    local mlist = {}
    for _,v in ipairs(enabler.extras) do
        table.insert(mlist, require(v))
    end
    return mlist
end

-- wraps the default connect function and issues callbacks
-- to any included modules so that they can also wrap whatever
-- they need.
function enabler.connect(udid)
    local extras = extra_modules()
    local conn = enabler.ios.connect(udid)
    for _,m in ipairs(extras) do
        if m.on_connect then m.on_connect(conn) end
    end
    return enabler.patch_connection(conn, extras)
end

function enabler.patch_connection(conn, extras)
    -- create wrapper icons object (real one is userdata and can't
    -- be modified to the extended needed by lua code
    local w = {}
    setmetatable(w, {
        __index = function(table, key)
            local res = conn[key]
            if type(res) == "function" then
                return function(t, ...) return conn[key](conn, ...) end
            else 
                return res
            end
        end
    })

    -- update the icons function
    w.icons = function(t)
        local res = conn:icons()
            for _,m in ipairs(extras) do
                if m.on_icons then m.on_icons(res, conn) end
            end
        return res
    end
    w.get_icons = w.icons
    return w
end

-- for the impatient types
function enabler.gimme(udid)
    local conn = enabler.connect(udid)
    local icons = conn:icons()
    return conn,icons
end

-- be as ios-icons.
-- be as ios-icons as possible.
setmetatable(enabler, {
    __index = function(table, key)
        local r = enabler.ios[key]
        if type(r) == "function" then 
            return function(...) return r(enabler.ios, ...) end
        else 
            return r 
        end
    end
})

return enabler