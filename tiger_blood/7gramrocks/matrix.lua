local ios = require "ios-icons.tiger-blood"

-- did not really end up to the quality I'd hoped ;(

hrows = {
    "-- 30251748    13786369    73696104    52356961    38031921",
    "-- 76325578    65434141    33000112    58204857    16561275",
    "-- 62062590    68525  ________________  0792891    95158195",
    "-- 47851002    74013 | SYSTEM FAILURE | 4286564    23383286",
    "-- 84281049    09137  ----------------  3090413    65779473",
    "-- 73193727    18260754    18560309    92091025    01055398",
    "-- 73312099    76000918    33926366    35273946    14039577",
}
co_head = coroutine.wrap(function() for _,v in pairs(hrows) 
          do print(v) ; coroutine.yield() end end)
function hrow() pcall(co_head) end 

conn,icons = ios.gimme()
local pageno = 2 -- (where 1 = the dock)

function shuffle(tbl, len, times)
    for i=1,times do
        local a = math.random(1,len)
        local b = math.random(1,len)
        local tmp = tbl[a]
        tbl[a] = tbl[b]
        tbl[b] = tmp
    end
end

function prep_page()
    icons:cache_colors()
    black = icons:dark()
    green = icons:with_hue_range(110, 130)
    return black,green
end

function black_and_green()
    local black,green = prep_page()
    return coroutine.wrap(function()
        for _,v in ipairs(black) do
            coroutine.yield(v)
        end
        for _,v in ipairs(green) do
            coroutine.yield(v)
        end
    end)    
end

function genpage()
    hrow()
    flat = icons:flatten()
    local co = black_and_green()
    local dock_icons = icons:dock()

    idx = 1
    while true do
        hrow()
        local i = co()
        if not i then break end
        table.insert(flat, idx, i)
        idx = idx + 1
    end

    math.randomseed(os.time())
    shuffle(flat, #black + #green, #black * #green)

    idx = 1
    for _,v in ipairs(dock_icons) do
        table.insert(flat, idx, v)
        idx = idx + 1
    end

    conn:set_icons(icons.reshape(flat))
    return conn:icons()
end


function single_frame(icons)
    local page = icons[pageno]
    local cols = icons.layout.cols

    for i=1,cols do
        if math.random(1,100) > 60 then
            icons.actions.transforms.col_d(page, i)
        end
    end
end

icons = genpage()
icons:animate( icons.actions.wait_for_input(
        function()
            return single_frame(icons)
        end
    ) 
)


conn:disconnect()


