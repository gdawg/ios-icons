local cache = {}

function cache.new(path)
    local c = { }

    _,_,rc = os.execute("test -d " .. path)
    if rc == 1 then os.execute("mkdir " .. path) end

    c.get = function(k, generate)
        local data = nil
        local fd = io.open(path .. "/" .. k, "rb")
        if fd then data = fd:read("*all") ; fd:close() end
        if not data and type(generate) == "function" then
            data = generate()
            c.store(k, data)
        end
        return data        
    end

    c.store = function(k, v)
        local fd = io.open(path .. "/" .. k, "wb")
        fd:write(v)
        fd:close()
    end

    setmetatable(c, {
        __tostring = function() return "cache[" .. path .. "]" end,
    })
    return c
end

return cache
