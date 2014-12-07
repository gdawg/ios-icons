#ifndef ICONS_H

struct lua_State;

static char *const kSavePlistMethodName = "save_plist";
static char *const kGetImageDataName = "imagedata";

int ios_get_icons(lua_State *L);
int ios_set_icons(lua_State *L);
int ios_icon_imagedata(lua_State* L);

#define ICONS_H 1
#endif