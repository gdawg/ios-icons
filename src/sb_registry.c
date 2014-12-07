#include <stdio.h>

#include <lua.h>
#include <lauxlib.h>

#include <plist/plist.h>

#include "ios-icons.h"

#define NEVER_NULL(S) (S == NULL) ? "" : S
static const char RegKey = 'k';

static int
uncheckedGetIconStore(lua_State* L) 
{
  lua_pushlightuserdata(L, (void *)&RegKey);
  lua_gettable(L, LUA_REGISTRYINDEX);
  return 1;    
}

static int
getIconStore(lua_State* L) 
{
  uncheckedGetIconStore(L);
  if (lua_isnoneornil(L, -1))
  {
    lua_pop(L, 1); 
    lua_pushlightuserdata(L, (void *)&RegKey);
    lua_newtable(L);
    lua_settable(L, LUA_REGISTRYINDEX);
    uncheckedGetIconStore(L); 
  }
  return 1;
}

void
makeIconRegRegKey(lua_State* L, 
                  const char* name, 
                  const char* id)
{
  luaL_Buffer B;
  luaL_buffinit(L, &B);
  luaL_addstring(&B, NEVER_NULL((char*)name));
  luaL_addchar(&B, '.');
  luaL_addstring(&B, NEVER_NULL((char*)id));
  luaL_pushresult(&B);
}

void 
storeIconInRegistry(lua_State* L, 
                     plist_t icon,
                     const char* name,
                     const char* id)
{
  const char* k;

  getIconStore(L);

  makeIconRegRegKey(L, name, id);
  k = lua_tostring(L, -1);
  lua_pushlightuserdata(L, (void *)icon);
  lua_setfield(L, -3, k);
  lua_pop(L, 2); // pop off icon store and RegKey
}

plist_t 
retrieveIconFromRegistry(lua_State* L,
                         const char* name,
                         const char* id)
{
  plist_t node = NULL;

  getIconStore(L);

  makeIconRegRegKey(L, name, id);
  lua_getfield(L, -2, lua_tostring(L, -1));

  node = lua_touserdata(L, -1);

  lua_pop(L, 3); // pop off icon, RegKey, store
  return node;
}

