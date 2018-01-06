#!/bin/sh
mkdir -p ${DSTROOT}/usr/share/man/man1
sed -e 's|^%%THREADS%%|\.\\"|' -e 's|^%%NLS%%|\.\\"|' < ${SRCROOT}/sort/sort.1.in > ${DSTROOT}/usr/share/man/man1/sort.1
