#!/bin/sh
set -ex

# Make -lcurl work.
ln -s "$FULL_PRODUCT_NAME" "$INSTALL_DIR"/libcurl.dylib

# Legacy compatibility.
if [ "$PLATFORM_NAME" = "macosx" ]; then
	ln -s "$FULL_PRODUCT_NAME" "$INSTALL_DIR"/libcurl.3.dylib
fi
