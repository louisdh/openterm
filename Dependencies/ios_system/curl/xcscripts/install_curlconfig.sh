#!/bin/sh
set -ex

if [ "$PLATFORM_NAME" != "macosx" ]; then
	exit 0
fi

curlver_h="$PROJECT_DIR"/curl/include/curl/curlver.h

major=`grep '^#define LIBCURL_VERSION_MAJOR ' "$curlver_h" | awk '{print $3}'`
minor=`grep '^#define LIBCURL_VERSION_MINOR ' "$curlver_h" | awk '{print $3}'`
patch=`grep '^#define LIBCURL_VERSION_PATCH ' "$curlver_h" | awk '{print $3}'`
CURLVERSION=$major.$minor.$patch

VERSIONNUM=`grep '^#define LIBCURL_VERSION_NUM ' "$curlver_h" | cut -f2 -dx`

${SED} \
	-e "s|@prefix@|${CURL_PREFIX}|" \
	-e "s|@exec_prefix@|${CURL_PREFIX}|" \
	-e "s|@includedir@|${CURL_PREFIX}/include|" \
	-e "s|@libdir@|${CURL_PREFIX}/lib|g" \
	-e 's|@ENABLE_SHARED@|yes|' \
	-e 's|@CURL_CA_BUNDLE@||' \
	-e 's|@CC@|cc|' \
	-e "s|@SUPPORT_FEATURES@|${CURL_SUPPORT_FEATURES}|" \
	-e "s|@SUPPORT_PROTOCOLS@|${CURL_SUPPORT_PROTOCOLS}|" \
	-e "s|@CURLVERSION@|${CURLVERSION}|" \
	-e "s|@VERSIONNUM@|${VERSIONNUM}|" \
	-e "s|@CONFIGURE_OPTIONS@|${CURL_CONFIGURE_OPTIONS}|" \
	-e "s|@CPPFLAG_CURL_STATICLIB@||" \
	"$PROJECT_DIR"/curl/curl-config.in > \
	"$TEMP_DIR"/curl-config

install -m 0755 "$TEMP_DIR"/curl-config "$INSTALL_DIR"/curl-config
