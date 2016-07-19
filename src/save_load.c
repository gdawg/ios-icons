#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>
#include <errno.h>
#include <sys/stat.h>
#include <lauxlib.h>

#include <plist/plist.h>

#include "springboard.h"

void
raise_lua_stdio_err(lua_State *L)
{
  if (errno == 0) { lua_pushstring(L, "unknown error!"); }  
  else { lua_pushstring(L, strerror(errno) ); }
  lua_error(L);
}

void
raise_lua_nomem(lua_State *L)
{
  lua_pushstring(L, "ENOMEM");
  lua_error(L);
}

int
savePList(plist_t* iconState, const char* path)
{
  char* xml = NULL;
  uint32_t len = 0;
  FILE* fd;

  fd = fopen(path, "w");
  if (fd == NULL) { return 1; }

  plist_to_xml(iconState, &xml, &len);

  fwrite(xml, sizeof(char), len, fd);
  fflush(fd);
  fclose(fd);
  free(xml);

  return 0;
}

int 
ios_save_icons_plist(lua_State *L)
{
  plist_t iconState;
  const char* path;

  path = luaL_checkstring(L, -1);
  lua_pop(L, 1);
  iconState = ios_table_to_plist(L); 
  lua_pop(L, 1);

  if (savePList(iconState, path))
  {
    luaL_error(L, "failed to save: %s", 
                  strerror(errno));
  }

  return 0;
}

int 
ios_load_icons_plist(lua_State *L)
{
  plist_t iconState = NULL;
  const char* path;
  int fd;
  void *mem;
  size_t sz;

  path = lua_tostring(L, -1);

  if ((fd = open(path, O_RDONLY) < 0))
    luaL_error(L, "open %s failed: %s", path, strerror(errno));

  sz = lseek(fd, 0, SEEK_END);
  (void)lseek(fd, 0, SEEK_SET);

  mem = mmap(NULL, sz, PROT_READ, MAP_PRIVATE, fd, 0);
  (void)close(fd);

  if (mem == MAP_FAILED)
    luaL_error(L, "reading %s failed: %s", path, strerror(errno));

  plist_from_xml((char*)mem, strlen((char*)mem), &iconState);

  (void)munmap(mem, sz);

  lua_pop(L, 1);

  return ios_plist_to_table(L, iconState);
}

