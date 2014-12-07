#include <stdio.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>

#include <plist/plist.h>

#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/lockdown.h>
#include <libimobiledevice/sbservices.h>

#include "ios-icons.h"
#include "comms.h"
#include "icons.h"

int idevice_errno = 0;

LUALIB_API int ios_connect(lua_State *L)
{
  int rc;
  const char* udid = NULL;

  if (lua_gettop(L) > 0)
  {
    udid = lua_isnoneornil(L, -1) ? NULL : lua_tostring(L, 1);
    lua_pop(L, 1);    
  }

  SBConnection* c = (SBConnection*)lua_newuserdata(L, sizeof(SBConnection));
  memset(c, 0, sizeof(SBConnection));
  luaL_getmetatable(L, kSpringboardConnID);
  lua_setmetatable(L, -2);

  if (( IDEVICE_E_SUCCESS == (rc = idevice_new( &c->device, udid)))
     
     && LOCKDOWN_E_SUCCESS == (rc = lockdownd_client_new_with_handshake(
                                c->device,&c->lockdownClient, kClientId))
     
     && LOCKDOWN_E_SUCCESS == (rc = lockdownd_start_service(
        c->lockdownClient, kSpringboardServices, &c->lockdownService))
     
     && SBSERVICES_E_SUCCESS == (rc = sbservices_client_new(
          c->device, c->lockdownService,  &c->sbClient))) 
  {

    return 1;
  } 
  else 
  {
      ios_disconnect(L);
      idevice_errno = rc;

      lua_pushfstring(L, "%s code=%d", kConnectFail, rc);
      lua_error(L);
      
      return 0; // never reached
  }
}

LUALIB_API int ios_disconnect(lua_State *L)
{
  SBConnection* c = (SBConnection*)luaL_checkudata(L, 1, kSpringboardConnID);
  if (c->sbClient != NULL) { sbservices_client_free(c->sbClient); }
  if (c->lockdownService != NULL) { lockdownd_service_descriptor_free(c->lockdownService); }
  if (c->lockdownClient != NULL) { lockdownd_client_free(c->lockdownClient); }
  if (c->device != NULL) { idevice_free(c->device); }
  memset(c, 0, sizeof(SBConnection));

  lua_pop(L, 1); // connection
  return 1;
}

int conn_tostring(lua_State *L) {
  char* deviceName;

  SBConnection* c = (SBConnection*)luaL_checkudata(L, 1, kSpringboardConnID);
  if (c->lockdownClient == NULL) { lua_pushstring(L, "disconnected"); }
  else
  {
    if ( lockdownd_get_device_name(c->lockdownClient, 
            &deviceName) == LOCKDOWN_E_SUCCESS) 
         { lua_pushfstring(L, "ios[%s]", deviceName); }
    else { lua_pushstring(L, "unknown"); }
  }
  return 1;
}

int ios_errno(lua_State *L)
{
    lua_pushinteger(L, idevice_errno);
    return 1;
}
