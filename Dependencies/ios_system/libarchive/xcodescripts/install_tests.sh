#!/bin/sh

mkdir -m 0755 -p ${DSTROOT}/AppleInternal/Tests/libarchive
install -m 0755 ${SRCROOT}/tests/*.sh ${DSTROOT}/AppleInternal/Tests/libarchive
install -m 0644 ${SRCROOT}/tests/*.tar ${DSTROOT}/AppleInternal/Tests/libarchive
