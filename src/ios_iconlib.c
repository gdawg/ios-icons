#include <stdio.h>

#include <lua.h>
#include <lauxlib.h>

#include "ios-icons.h"
#include "comms.h"
#include "save_load.h"
#include "icons.h"

static const char* kLuaIndexMetaKey = "__index";

static const luaL_Reg iconlib_methods[] = {
  { "connect", ios_connect }, 
  { "ios_errno", ios_errno }, 
  { "load_plist", ios_load_icons_plist },
  { NULL, NULL }
};

static const luaL_Reg sbconn_methods[] = {
  { "disconnect", ios_disconnect }, 
  { "icons", ios_get_icons }, 
  { "get_icons", ios_get_icons }, 
  { "set_icons", ios_set_icons }, 
  { "icon_image", ios_icon_imagedata }, 
  { "__tostring", conn_tostring }, 
  { NULL, NULL }
};

LUALIB_API int
luaopen_icons_iconlib(lua_State *L)
{
  luaL_newmetatable(L, kSpringboardConnID); // connection obj
  lua_pushstring(L, kLuaIndexMetaKey);
  lua_pushvalue(L, -2); /* pushes the metatable */
  lua_settable(L, -3);  /* metatable.__index = metatable */  
  luaL_setfuncs(L, sbconn_methods, 0); // 
  lua_pop(L, 1);  /* pop new metatable */

  luaL_newmetatable(L, kLibraryRegKey);
  luaL_newlib(L, iconlib_methods);

  return 1;
}
