#!/bin/sh
set -ex

mkdir -p "$DSTROOT"/usr/local/OpenSourceVersions
install -m 0644 "$PROJECT_DIR"/curl.plist "$DSTROOT"/usr/local/OpenSourceVersions/curl.plist
mkdir -p "$DSTROOT"/usr/local/OpenSourceLicenses
install -m 0644 "$PROJECT_DIR"/curl/COPYING "$DSTROOT"/usr/local/OpenSourceLicenses/curl.txt
