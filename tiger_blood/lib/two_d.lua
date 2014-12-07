local two_d = {
    pivot = function(tbl)
        local r = {}
        for x,c in ipairs(tbl) do for y,p in ipairs(c) do
            if not r[y] then r[y] = {} end r[y][x] = p end
        end
        return r
    end,
    shuffle = function(tbl, times)
        local len = #tbl
        for i=1,times do
            local a = rand_xy(tbl)
            local b = rand_xy(tbl)
            local tmp = tbl[a.x][a.y]
            tbl[a.x][a.y] = tbl[b.x][b.y]
            tbl[b.x][b.y] = tmp
        end
        return tbl
    end,
    copy = function(tbl)
        local r = {}
        for i,row in pairs(tbl) do 
            r[i] = {} 
            if type(row) == "table" then
                for j,v in pairs(row) do r[i][j] = v end
            end
        end
        return r
    end,
    random_idx = function(tbl)
        local x = math.random(#tbl)
        local y = math.random(#tbl[x])
        return { x = x, y = y } 
    end
}

return two_d