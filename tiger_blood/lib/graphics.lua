local graphics = {}
local image = require "ios-icons.image"
local fn = require "ios-icons.fn"

function graphics.on_icons(icons, conn)
    if not icons then error("icons must be provided!") end
    if not conn then error("connection must be provided!") end

    icons:visit(function(icon)
        -- add image functions to anything with bundleIdentifier
        if icon.bundleIdentifier then
            icon.imagedata = function() return conn:icon_image(icon) end
            icon.image = image.new(icon)
        end
    end)

    icons.with_image = function(tbl)
        return fn.select(tbl:flatten(), function(i) return i.image end)
    end

    icons.with_color = function(tbl, c)
        return fn.select(tbl:with_image(), function(i) 
            return i.image.color() == c
        end)
    end

    icons.with_hue_range = function(tbl, lo, hi)
        return fn.select(tbl:with_image(), function(i) 
            h,s,v = i.image.hsv()
            return h >= lo and h <= hi
        end)
    end

    icons.dark = function(tbl, c)
        return fn.select(tbl:with_image(), function(i) 
            return i.image.is_dark()
        end)
    end

    icons.cache_colors = function(icons)
        for _,i in ipairs(icons:with_image()) do
            local v = i.image.color()
        end
    end

end

return graphics