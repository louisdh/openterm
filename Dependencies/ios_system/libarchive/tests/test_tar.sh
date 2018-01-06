#!/bin/sh

SCRIPTDIR=`dirname "$0"`
STATUS=0
SCRATCHDIR=`mktemp -d -t test_tar`

printf "[TEST] tar\n"

printf "[BEGIN] Radar 26496124\n"
/usr/bin/tar -C "${SCRATCHDIR}" -xvf "${SCRIPTDIR}"/radar-26496124.tar
if [ $? -eq 1 ]; then
    printf "\n[PASS] Radar 26496124\n"
else
    STATUS=$?
    printf "\n[FAIL] Radar 26496124\n"
fi

printf "[BEGIN] Radar 26561820\n"
/usr/bin/tar -C "${SCRATCHDIR}" -xvf "${SCRIPTDIR}"/radar-26561820.tar
if [ $? -eq 1 ]; then
    printf "\n[PASS] Radar 26561820\n"
else
    STATUS=$?
    printf "\n[FAIL] Radar 26561820\n"
fi

printf "[BEGIN] Radar 28015866\n"
/usr/bin/tar -tvf "${SCRIPTDIR}"/radar-28015866.tar
if [ $? -eq 1 ]; then
    printf "\n[PASS] Radar 28015866\n"
else
    STATUS=$?
    printf "\n[FAIL] Radar 28015866\n"
fi

printf "[BEGIN] Radar 28024754\n"
/usr/bin/tar -C "${SCRATCHDIR}" -xvf "${SCRIPTDIR}"/radar-28024754.tar
if [ $? -eq 1 ]; then
    printf "\n[PASS] Radar 28024754\n"
else
    STATUS=$?
    printf "\n[FAIL] Radar 28024754\n"
fi

printf "[BEGIN] Radar 28101193\n"
rm -f /tmp/myfile
/usr/bin/tar -C "${SCRATCHDIR}" -xvf "${SCRIPTDIR}"/radar-28101193.tar
if [ $? -eq 1 ] && [ ! -f /tmp/myfile ]; then
    printf "\n[PASS] Radar 28101193\n"
else
    STATUS=$?
    printf "\n[FAIL] Radar 28101193\n"
fi

chmod -R 0777 "${SCRATCHDIR}"
rm -fr "${SCRATCHDIR}"

exit $STATUS
