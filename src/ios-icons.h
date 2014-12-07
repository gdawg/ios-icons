#ifndef IOS_ICONS_H

struct lua_State;

static char *const kLibraryRegKey = "iOS.icons";

// imobiledevice related
static const char* kSpringboardInfoVersion = "2";
static const char* kSpringboardServices = "com.apple.springboardservices";
static const char* kClientId = "iosIcons";

static char *const kSpringboardConnID = "idevice_conn";

static const char* kSetIconsErr = "error setting icons";
static const char* kFailNoConnection = "failed! no connection.";
static const char* kConnectFail = "error communicating with device. ";
static const char* kUnknownIconData = "unable to find app for icon!";

extern int idevice_errno;

#define IOS_ICONS_H 1
#endif

