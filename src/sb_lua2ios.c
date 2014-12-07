#include <stdio.h>
#include <lua.h>
#include <lauxlib.h> 

#include <libimobiledevice/libimobiledevice.h>

#include "ios-icons.h"
#include "springboard.h"

int addPageIconsToPList(lua_State* L, plist_t page);
void addIconsToGroup(lua_State* L, plist_t group);

plist_t ios_table_to_plist(lua_State* L)
{
  plist_t iconState, p;
  iconState = plist_new_array();
  int i;

  if (lua_type(L, -1) != LUA_TTABLE) {
    luaL_error(L, "internal error! can't convert %s to icons", 
                  luaL_typename(L, -1));
  }

  // Iterate dock+pages
  int len = lua_rawlen(L, -1);
  for (i=1; i< len+1; i++) 
  {
    // push page to top of stack
    lua_rawgeti(L, -1, i);

    // create plist page to match
    if (lua_istable(L, -1))
    {
      p = plist_new_array(); 
      plist_array_append_item(iconState, p);
      addPageIconsToPList(L, p);
    }

    lua_pop(L, 1);
  }

  return iconState;
}

plist_t luaToStoredPListItem(lua_State* L)
{
  plist_t pageItem;

  lua_getfield(L, -1, kIconName);
  lua_getfield(L, -2, kIconId);

  pageItem = retrieveIconFromRegistry(L, 
                    lua_tostring(L, -2),
                    lua_tostring(L, -1));

  if (pageItem == NULL) 
  { 
    luaL_error(L, "%s (name=%s, id=%s)", 
                    kUnknownIconData, 
                    lua_tostring(L, -2), 
                    lua_tostring(L, -1));
  }

  lua_pop(L, 2); // name + id

  return pageItem;
}

int addPageIconsToPList(lua_State* L, plist_t page)
{
  plist_t pageItem;
  int i;

  int len = lua_rawlen(L, -1);
  for (i=1; i< len+1; i++) 
  {
    lua_rawgeti(L, -1, i); 
    pageItem = luaToStoredPListItem(L);

    lua_getfield(L, -1, kIconsKey);
    if (! lua_isnoneornil(L, -1)) 
    {
      pageItem = plist_copy(pageItem);
      addIconsToGroup(L, pageItem);
    } 
    lua_pop(L, 1);

    plist_array_append_item(page, pageItem);
    lua_pop(L,1); // pop page elem off
  }
  return 0;
}

void addIconsToGroup(lua_State* L, plist_t group)
{
  plist_t wasteful_format = plist_new_array();
  plist_t children = plist_new_array();
  plist_array_append_item(wasteful_format, children);
  int i;

  int len = lua_rawlen(L, -1);
  for (i=1; i< len+1; i++) 
  {
    lua_rawgeti(L, -1, i); 
    plist_array_append_item(children, luaToStoredPListItem(L));
    lua_pop(L,1); // pop page elem off    
  }
  plist_dict_set_item(group, kAppleIconListKey, wasteful_format);
}

