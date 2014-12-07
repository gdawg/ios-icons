#ifndef SAVE_LOAD_H
#include <lua.h>

int ios_save_icons_plist(lua_State *L);
int ios_load_icons_plist(lua_State *L);

int savePList(plist_t* iconState, const char* path);

#endif
