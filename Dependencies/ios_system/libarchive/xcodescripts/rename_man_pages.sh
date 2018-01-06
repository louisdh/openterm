#!/bin/sh

set -ex

if [ "${RC_ProjectName%_Sim}" != "${RC_ProjectName}" ] ; then
	[ -z "${DSTROOT}" ] && exit 1
	[ -d "${DSTROOT}/usr/share" ] && rm -rf "${DSTROOT}/usr/share"
	exit 0
fi

mv ${DSTROOT}/usr/share/man/man1/bsdcpio.1 ${DSTROOT}/usr/share/man/man1/cpio.1
