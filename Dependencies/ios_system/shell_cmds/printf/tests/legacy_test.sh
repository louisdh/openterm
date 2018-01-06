#!/bin/sh
# $FreeBSD: head/usr.bin/printf/tests/legacy_test.sh 263227 2014-03-16 08:04:06Z jmmv $

SRCDIR="$(dirname "${0}")"; export SRCDIR

m4 /AppleInternal/Tests/shell_cmds/regress.m4 "${SRCDIR}/regress.sh" | sh
