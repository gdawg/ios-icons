package = "ios-icons.tiger-blood"
version = "1.0-1"
source = {
   url = "https://github.com/gdawg/ios-icons.git"
}
description = {
   summary = "Extends the 'ios-icons' rock with tiger-blood functionality",
   detailed = "Adds methods to the 'ios-icons' rock TO BE DONE",
   homepage = "https://github.com/gdawg/ios-icons.tiger-blood/",
   license = "MIT"
}
dependencies = {
   "ios-icons",
   "luajson",
   "luasocket",   
}
external_dependencies = {
   GRAPHICS_MAGICK = { program = "gm" },
}
build = {
   type = "builtin",
   modules = {   
      ["ios-icons.tiger-blood"] = "lib/tiger-blood.lua",
      ["ios-icons.itunes"] = "lib/itunes.lua",
      ["ios-icons.math"] = "lib/math.lua",
      ["ios-icons.image"] = "lib/image.lua",
      ["ios-icons.graphics"] = "lib/graphics.lua",
      ["ios-icons.animation"] = "lib/animation.lua",
      ["ios-icons.two_d"] = "lib/two_d.lua",
      ["ios-icons.cache"] = "lib/cache.lua",
      ["ios-icons.tigerc"] ={
         sources = { "src/tigerblood.c" },
      } 
   },
}
