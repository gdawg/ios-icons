#ifndef SPRINGBOARD_H
#define SPRINGBOARD_H 1
#include <plist/plist.h>
#include <lua.h>
#include "comms.h"

static char *const kIconUserDataType = "ios-icons.icon";
static char *const kAppleDisplayIDKey = "displayIdentifier";
static char *const kAppleDisplayNameKey = "displayName";
static char *const kAppleIconListKey = "iconLists";
static char *const kAppleBundleIdKey = "bundleIdentifier";
static char *const kIconName = "name";
static char *const kIconId = "id";
static char *const kIconsKey = "icons";
static char *const kIconCollectionTypeKey = "ios-icons.icons";
static char *const kPageTypeKey = "ios-icons.page";
static char *const kConnIDName = "connection";


int ios_plist_to_table(lua_State* L, plist_t iconState);
plist_t ios_table_to_plist(lua_State* L);

void storeIconInRegistry(lua_State* L,
                         plist_t icon,
                         const char* name,
                         const char* id);

plist_t retrieveIconFromRegistry(lua_State* L,
                                 const char* name,
                                 const char* id);

#endif

