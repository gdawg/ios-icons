#include <stdio.h>
#include <lua.h>
#include <lauxlib.h> 

#include <libimobiledevice/libimobiledevice.h>

#include "ios-icons.h"
#include "springboard.h"

int addPageIconsToPList(lua_State* L, plist_t page);
void addIconsToGroup(lua_State* L, plist_t group);

plist_t 
ios_table_to_plist(lua_State* L)
{
  plist_t iconState;
  iconState = plist_new_array();
  int i;

  // Iterate dock+pages
  luaL_checktype(L, -1, LUA_TTABLE);
  int len = lua_rawlen(L, -1);

  for (i=1; i< len+1; i++) 
  {    
    plist_t p;

    // push page to top of stack
    lua_rawgeti(L, -1, i); 
    luaL_checktype(L, -1, LUA_TTABLE);

    // create plist page to match
    p = plist_new_array(); 
    plist_array_append_item(iconState, p);
    addPageIconsToPList(L, p);

    lua_pop(L, 1);
  }

  return iconState;
}

plist_t 
luaToStoredPListItem(lua_State* L)
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

  // "trim " the stored icon a little as a workaround for data failures
  plist_dict_remove_item(pageItem, "iconModDate");
  plist_dict_remove_item(pageItem, "bundleVersion");
  plist_dict_remove_item(pageItem, "bundleIdentifer");
  plist_dict_remove_item(pageItem, "displayName");

  lua_pop(L, 2); // name + id

  return pageItem;
}

int 
addPageIconsToPList(lua_State* L, plist_t page)
{
  int i;

  int len = lua_rawlen(L, -1);
  for (i=1; i< len+1; i++) 
  {
    plist_t pageItem;
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

void 
addIconsToGroup(lua_State* L, plist_t group)
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

