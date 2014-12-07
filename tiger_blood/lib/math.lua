local math = {}

function math.rgb_to_hsv(r, g, b)
    local sorted, min, max, v, delta, h, s, v
    
    sorted = { r, g, b }
    table.sort(sorted)
    min = sorted[1]
    max = sorted[3]
    v = max

    delta = max - min
    if max == 0 then
        s = 0
        h = -1
        return h,s,v
    else
        s = delta / max 
    end

    if r == max then
        h = (g - b) / delta
    elseif g == max then
        h = 2 + (b - r) / delta
    else
        h = 4 + (r - g) / delta
    end

    h = h * 60
    if h < 0 then h = h + 360 end

    return h,s,v
end


return math