ios = require "ios-icons.tiger-blood"
tc = require "ios-icons.tigerc"
table.two_d = require "ios-icons.two_d"
pageno = 2

-- build a lookup table where the icons in the outer ring are
-- rotated ccw for a neverending rotation animation
function circlework_lookup_table(icons)
    local lut = icons.anim_utils.lookup_table.new()
    local rows,cols = icons.layout.rows_and_cols()
    local lbak = table.two_d.copy(lut)

    for i=1,cols-1 do 
        lut[i][1] = lbak[i+1][1]
        lut[i+1][rows] = lbak[i][rows] 
    end
    for i=2,rows-1 do 
        lut[1][i+1] = lbak[1][i] 
        lut[cols][i-1] = lbak[cols][i] 
    end
    lut[1][2] = lbak[1][1]
    lut[cols][rows-1] = lbak[cols][rows]

    return lut
end

-- connect, get icons
local conn,icons = ios.gimme()
lookup_table = circlework_lookup_table(icons)

-- print(lookup_table)
-- lookup_table:validate()

icons:animate( icons.actions.wait_for_input(
        icons.actions.lookup_transform(icons[pageno], lookup_table) 
    )
)

conn:disconnect()
