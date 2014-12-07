#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/types.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#include <lua.h>
#include <lauxlib.h>

static const char* kTigerBlood = "tigaaaRaaah";

int
lua_ext_getc(lua_State* L)
{
  fd_set rfds;
  struct timeval tv;
  int rc;

  long timeout = luaL_checklong(L, -1);
  lua_pop(L, 1);

  tv.tv_sec = (time_t) timeout / 1000;
  tv.tv_usec = (time_t) timeout % 1000;

  FD_ZERO(&rfds); 
  FD_SET(STDIN_FILENO, &rfds); 

  rc = select(1, &rfds, NULL, NULL, &tv);
  if (rc == -1) { luaL_error(L, "%s", strerror(errno)); }
  if (rc != 0) {
    lua_pushfstring(L, "%c", fgetc(stdin));
  } else {
    lua_pushnil(L);
  }
  return 1;
}



static const luaL_Reg iconlib_methods[] = {
  { "getc", lua_ext_getc }, 
  { NULL, NULL }
};

LUALIB_API int
luaopen_icons_tigerc(lua_State *L)
{
  luaL_newmetatable(L, kTigerBlood);
  luaL_newlib(L, iconlib_methods);
  return 1;
}

