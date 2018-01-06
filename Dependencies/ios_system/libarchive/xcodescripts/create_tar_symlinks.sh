#!/bin/sh

set -ex

# check if we're building for the simulator
[ "${RC_ProjectName%_Sim}" != "${RC_ProjectName}" ] && exit 0

ln -s bsdtar ${DSTROOT}/usr/bin/tar
ln -s bsdtar.1 ${DSTROOT}/usr/share/man/man1/tar.1
