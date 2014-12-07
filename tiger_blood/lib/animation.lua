local anim = {
    interval = 1.0,
}
local layout = {} -- configured on fetch
local info = {}

inspect = require("inspect")
function pp(x) print(inspect(x)) end

-- ANIMATION UTILS --
local socket = require "socket"
local tc = require "ios-icons.tigerc"
local utils = {
    set_rate = function(r) anim.interval = r end,
    sleep = function(sec) socket.select(nil, nil, sec) end,

    -- "fancy" read w/ timeout
    read = function(t)
        rfd = socket.select({io.stdin}, nil, t)
        if #rfd > 0 then
            return io.read()
        end
    end,
}
local function tick() io.write(".") ; io.flush() end

-- Animation controller, iterates over frames holding
--  - connection for setting icons
--  - icons to be animated
--  - animation current state data
--  - actions to be applied at each frame
function anim.play(conn, icons, data, actions)
    if type(actions) == "function" then actions = {actions} end
    io.write("animating " .. #actions .. " actions: ")
    io.flush()
    local kept
    while #actions > 0 do
        -- run actions, remove any which finish
        kept = {}
        for _,v in ipairs(actions) do
            info.calling = { f = v, data = data }
            if v(data) then table.insert(kept, v) end
        end

        conn:set_icons(icons)
        utils.sleep(anim.interval)

        -- calculate new icon positions for next frame
        data.pos = icons:positions()
        data.frame = data.frame + 1
        actions = kept

        tick()
    end
    io.write("\n")
end

local function dataset(icons)
    local ds = { frame = 0, 
        pos = icons:positions(), 
        p_idx = icons:page_indexes() 
    }
    return ds
end

-- PAGE 2D/1D INDEX UTILS
local page_math = {
    -- calcs peformed in 2d space
    xy = function(idx)
        local y = math.ceil(idx / layout.cols)
        local x = ((idx - 1) % layout.cols) + 1
        return { x=x, y = y }
    end,

    -- add vec to position (2d space)
    add = function(pos_xy, vec_xy)
        return { pos_xy[1] + vec_xy[1], 
                 pos_xy[2] + vec_xy[2] }
    end,

    -- convert back to 1d pos for real placement (support offsets)
    idx = function(pos_xy)
        local rows,cols = layout.rows_and_cols()
        local len = rows * cols
        local xy = { x=pos_xy.x - 1, y=pos_xy.y - 1}
        local p = 1 + (xy.y * layout.cols) + xy.x
        while p < 1 do p = p + len end
        while p > len do p = p - len end
        return p
    end,


    indexed_to_xy = function(page)
        local rows,cols = layout.rows_and_cols()
        local res = {}
        for i,v in ipairs(page) do
            local y = math.ceil(i / layout.cols)
            local x = ((i - 1) % layout.cols) + 1
            if not res[x] then res[x] = {} end
            res[x][y] = v
        end
        return res
    end,

    xy_to_indexed = function(tbl)
        local rows = table.two_d.pivot(tbl)
        local res = {}
        for y,row in ipairs(rows) do
            for x,v in ipairs(row) do
                table.insert(res, v)
            end
        end
        return res
    end,

}

-- TABLE TRANSFORMATIONS (misdirected for use as animation actions)
local transforms = {
    col_d = function(tbl, num)
        local tmp = {} ; for k,v in pairs(tbl) do tmp[k] = v end
        setmetatable(tmp,getmetatable(tbl))
        local rows,cols = layout.rows_and_cols()
        local idx_b = num + (rows * cols) - cols
        local wrapped = tmp[idx_b]
        for i=num,idx_b-1,cols do
            tbl[i+cols] = tmp[i]
        end
        tbl[num] = wrapped
    end,    
}

-- LOOKUP TABLE (TRANSFORMATIONS)
local lookup_table = {}
local mt = {
    __index = {
        validate = function(tbl)
            local pos = lookup_table.new()
            for _,row in ipairs(tbl) do
                for _,xy in ipairs(row) do pos[xy.x][xy.y] = nil end
            end

            local missing = {}            
            for _,row in ipairs(pos) do for _,v in ipairs(row) do 
                if v then table.insert(missing, v.x .. "x" .. v.y) end 
            end end
            if #missing > 0 then 
                error("missing " .. table.concat(missing, ", ")) 
            end
        end,

        apply_to = function(lut, dest)
            local tmp = page_math.indexed_to_xy(dest)
            local src = table.two_d.copy(tmp)

            -- convert to 2d coords
            for x,col in ipairs(lut) do
                for y,pos in ipairs(col) do
                    tmp[x][y] = src[pos.x][pos.y]
                end
            end
            -- then back to 1d, apply destructively into dest
            for i,v in ipairs(page_math.xy_to_indexed(tmp)) do
                dest[i] = v
            end
            return dest
        end,
    },
    __tostring = function(tbl)
        local rows = table.two_d.pivot(tbl)
        local txt = {}
        for y,row in ipairs(rows) do
            local row_txt = {}
            for x,p in ipairs(row) do
                if x == p.x and y == p.y then 
                    table.insert(row_txt, ' - ')
                else
                    table.insert(row_txt, p.x .. "x" .. p.y)
                end
            end
            table.insert(txt, table.concat(row_txt, ", "))
        end
        return table.concat(txt, "\n")
    end
}

mt.__index.new = function()
    local tbl = {}
    local rows,cols = layout.rows,layout.cols
    for i=1,cols do
        if not tbl[i] then tbl[i] = {} end
        for j=1,5 do
            tbl[i][j] = {x=i, y=j}
        end
    end
    setmetatable(tbl, mt)
    return tbl
end
setmetatable(lookup_table, mt)

local conditions = {}
function conditions.user_input()
    return coroutine.wrap(function()
        io.write("enter to quit")
        while tc.getc(20) == nil do
            coroutine.yield(true)
        end
        coroutine.yield(false)
    end)
end
function conditions.ten_times()
    local co = coroutine.wrap(function()
        for i=1,10 do coroutine.yield(true) end
        coroutine.yield(false)
    end)
    return co
end
-- adds animation functions to icons object
function anim.on_icons(icons, conn)
    icons.animate = function(icons, actions)
        return anim.play(conn, icons,  dataset(icons), actions)
    end

    icons.actions = {
        wait_for_input = function(action_func)
            local run_while = conditions.user_input()
            local co = coroutine.wrap(function(data)
                while run_while() do 
                    action_func()
                    coroutine.yield(true)
                end
                coroutine.yield(false)
            end)
            return co
        end,
        transforms = transforms,
        lookup_transform = function(page, map)
            return function(data) map:apply_to(page) end
        end,

        -- inserted into grouped anims to skip updates for frame
        noop = function()
            return function()
            end
        end,

        -- group actions to run in parallel
        join = function(tbl)
            return function(data)
                for _,v in pairs(tbl) do v() end
            end
        end,
    }

    setmetatable(layout, {
        __index = function(tbl, key)
            if key == "columns" or key == "cols" then return layout.__cols
            elseif key == "rows" then return layout.__rows
            elseif key == "set_cols" then return function(cols)
                    layout.__cols = cols
                    local maxpp = -1
                    for _,p in ipairs(icons) do 
                        maxpp = math.max(maxpp, #p) 
                    end
                    layout.__rows = math.ceil(maxpp / layout.cols)
                end
            elseif key == "rows_and_cols" then 
                return function()
                    return layout.__rows,layout.__cols
                end
            end
        end  
    })
    icons.layout = layout
    icons.layout.set_cols(4) -- default to 4 columns

    icons.actions.set_columns = function(x) layout.cols = x end
    icons.actions.columns = function() return layout.cols end
    icons.anim_utils = utils
    icons.anim_utils.lookup_table = lookup_table
    icons.anim_info = info
end


return anim