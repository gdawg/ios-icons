#ifndef COMMS_H

#include <libimobiledevice/libimobiledevice.h>
#include <libimobiledevice/lockdown.h>
#include <libimobiledevice/sbservices.h>

struct lua_State;

LUALIB_API int ios_connect(lua_State *L);
LUALIB_API int ios_disconnect(lua_State *L);
LUALIB_API int conn_tostring(lua_State *L);
int ios_errno(lua_State *L);
extern int idevice_errno;

typedef struct _sbconn {
  idevice_t device;
  lockdownd_client_t lockdownClient;
  lockdownd_service_descriptor_t lockdownService;
  sbservices_client_t sbClient;
} SBConnection;


#define COMMS_H 1
#endif

