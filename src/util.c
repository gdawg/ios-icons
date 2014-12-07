#include <stdlib.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>

#include "ios-icons.h"
#include "util.h"

// prepopulates a table from another.
// used to add functionaily (coded in lua)
// to tables made directly from the clib.
int 
addToTable(lua_State *L, char* modname)
{
  int src, dest;

  dest = lua_absindex(L, -1);

  lua_getglobal(L, "require"); 
  lua_pushstring(L, modname);
  lua_call(L, 1, 1);
  src = lua_absindex(L, -1);

  lua_pushnil(L);
  while (lua_next(L, src) != 0) {
    if (lua_isstring(L, -2))
    {
      if (strcmp(lua_tostring(L, -2), "__meta") == 0)
      {
        lua_pushvalue(L, -1);
        lua_setmetatable(L, dest);
      }
      else
      {
        lua_pushvalue(L, -2);
        lua_pushvalue(L, -2);
        lua_rawset(L, dest);
      }
    }
    lua_pop(L, 1);
  }
  lua_pop(L, 1);
  return 1;
}


