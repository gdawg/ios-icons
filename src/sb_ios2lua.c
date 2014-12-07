#include <stdio.h>
#include <lua.h>

#include <plist/plist.h>

#include "ios-icons.h"
#include "icons.h"
#include "springboard.h"
#include "util.h"

// my underscore's.. umm, broken or something.
#define nodeType(X) plist_get_node_type(X)
#define dictEntry(D, K) plist_dict_get_item(D, K)
#define arrayElem(A, I) plist_array_get_item(A, I)
#define stringVal(N, V) plist_get_string_val(N, V)
#define getBool(N, B) plist_get_bool_val(N, B)
#define groupSize(X) plist_array_get_size(X)
#define dictSize(X) plist_dict_get_size(X)

void parseNode(lua_State* L, plist_t node, int depth);
char *getStringVal(plist_t dict, const char* key);
void flatPackArray(lua_State* L, plist_t node, int depth);

#define SET_STRING(L,K,V) lua_pushstring(L,V); lua_setfield(L,-2,K)

int ios_plist_to_table(lua_State* L, plist_t iconState)
{
  lua_newtable(L);
  parseNode(L, iconState, 0);
  lua_rawgeti(L, -1, 1);
  lua_remove(L, -2);
  return 1;
}

void parseNode(lua_State* L, plist_t node, int depth)
{
  char* name, *id, *bundleId;
  plist_t kids;
  int numChildren;
  int i;
  if (node == NULL) { return; }

  switch (nodeType(node)) 
  {
    case PLIST_DICT:
      lua_newtable(L);
      addToTable(L, kIconUserDataType);

      id = getStringVal(node, kAppleDisplayIDKey);
      name = getStringVal(node, kAppleDisplayNameKey);
      bundleId = getStringVal(node, kAppleBundleIdKey);
      kids = dictEntry(node, kAppleIconListKey);

      if (name == NULL && id == NULL) {
        lua_pushstring(L, "unexpected value reading icons!");
        lua_error(L);
      }

      if (name != NULL) { SET_STRING(L, kIconName,name); }
      if (id != NULL) { SET_STRING(L, kIconId,id); }
      if (bundleId != NULL) { SET_STRING(L, kAppleBundleIdKey,id); }
      storeIconInRegistry(L, node, name, id); 

      if (groupSize(kids) > 0) 
      {
        lua_newtable(L);
        flatPackArray(L, kids, depth+1);
        lua_setfield(L, -2, kIconsKey);
      }
      break;

    case PLIST_ARRAY:
      lua_newtable(L);
      addToTable(L, depth == 0 ? kIconCollectionTypeKey : kPageTypeKey);

      numChildren = groupSize(node);
      for (i=0;i<numChildren;i++) {
        parseNode(L, arrayElem(node, i), depth+1);
      }
    default:
      break;
    case PLIST_BOOLEAN:break;
    case PLIST_UINT:break;
    case PLIST_REAL:break;
    case PLIST_STRING:break;
    case PLIST_DATE:break;
    case PLIST_DATA:break;
    case PLIST_KEY:break;
    case PLIST_UID:break;
    case PLIST_NONE:break;
  }

  // append to the end of our parent container
  lua_rawseti(L, -2, lua_rawlen(L, -2) + 1);
}

// unfortunately we get back all groups double wrapped, seems
// apple was preparing for something that never came, if that
// day does come this might need to go
void flatPackArray(lua_State* L, plist_t node, int depth)
{
  int i;
  if (nodeType(node) == PLIST_ARRAY)
  {
    for (i=0;i<groupSize(node);i++) 
    {
      flatPackArray(L, arrayElem(node, i), depth);
    }      
  }
  else
  {
    parseNode(L, node, depth);
  }
}

char *getStringVal(plist_t dict, const char* key) 
{
  char* charVal = "";
  plist_t plistItem = dictEntry(dict, key);
  switch (nodeType(plistItem)) 
  {
    case PLIST_STRING:
      stringVal(plistItem,&charVal);
      break;
    default: // fall through to empty val.
    case PLIST_NONE:
      charVal = NULL;
      break;
  }
  return charVal;
}

