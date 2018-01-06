#!/bin/sh
set -ex

#
# This is from tests/libtest/Makefile.inc
# Less tedious than making an Xcode target for each item.
#

DEST_DIR="$TEMP_DIR"/libtest
CURL_INCLUDE="$PROJECT_DIR"/curl/include
LIB_DIR="$PROJECT_DIR"/curl/lib
LIBTEST_DIR="$PROJECT_DIR"/curl/tests/libtest

CC="cc -DHAVE_CONFIG_H -I${CURL_INCLUDE} -iquote${LIB_DIR} -iquote${PROJECT_DIR} -lcurl"

# files used only in some libcurl test programs
TESTUTIL="$LIBTEST_DIR"/testutil.c

# files used only in some libcurl test programs
TSTTRACE="$LIBTEST_DIR"/testtrace.c

# files used only in some libcurl test programs
WARNLESS="$LIB_DIR"/warnless.c

# these files are used in every single test program below
SUPPORTFILES="$LIBTEST_DIR"/first.c

mkdir -p "$DEST_DIR"
${CC} -o "$DEST_DIR"/chkhostname "$LIBTEST_DIR"/chkhostname.c "$LIB_DIR"/curl_gethostname.c
${CC} -o "$DEST_DIR"/libntlmconnect "$LIBTEST_DIR"/libntlmconnect.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/libauthretry "$LIBTEST_DIR"/libauthretry.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib500 "$LIBTEST_DIR"/lib500.c "$SUPPORTFILES" "$TESTUTIL" "$TSTTRACE"
${CC} -o "$DEST_DIR"/lib501 "$LIBTEST_DIR"/lib501.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib502 "$LIBTEST_DIR"/lib502.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib503 "$LIBTEST_DIR"/lib503.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib504 "$LIBTEST_DIR"/lib504.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib505 "$LIBTEST_DIR"/lib505.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib506 "$LIBTEST_DIR"/lib506.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib507 "$LIBTEST_DIR"/lib507.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib508 "$LIBTEST_DIR"/lib508.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib509 "$LIBTEST_DIR"/lib509.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib510 "$LIBTEST_DIR"/lib510.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib511 "$LIBTEST_DIR"/lib511.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib512 "$LIBTEST_DIR"/lib512.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib513 "$LIBTEST_DIR"/lib513.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib514 "$LIBTEST_DIR"/lib514.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib515 "$LIBTEST_DIR"/lib515.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib516 "$LIBTEST_DIR"/lib516.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib517 "$LIBTEST_DIR"/lib517.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib518 "$LIBTEST_DIR"/lib518.c "$SUPPORTFILES" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib519 "$LIBTEST_DIR"/lib519.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib520 "$LIBTEST_DIR"/lib520.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib521 "$LIBTEST_DIR"/lib521.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib523 "$LIBTEST_DIR"/lib523.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib524 "$LIBTEST_DIR"/lib524.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib525 "$LIBTEST_DIR"/lib525.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib526 "$LIBTEST_DIR"/lib526.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB526
${CC} -o "$DEST_DIR"/lib527 "$LIBTEST_DIR"/lib526.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB527
${CC} -o "$DEST_DIR"/lib529 "$LIBTEST_DIR"/lib525.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB529
${CC} -o "$DEST_DIR"/lib530 "$LIBTEST_DIR"/lib530.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB530
${CC} -o "$DEST_DIR"/lib532 "$LIBTEST_DIR"/lib526.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB532
${CC} -o "$DEST_DIR"/lib533 "$LIBTEST_DIR"/lib533.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib536 "$LIBTEST_DIR"/lib536.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib537 "$LIBTEST_DIR"/lib537.c "$SUPPORTFILES" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib539 "$LIBTEST_DIR"/lib539.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib540 "$LIBTEST_DIR"/lib540.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib541 "$LIBTEST_DIR"/lib541.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib542 "$LIBTEST_DIR"/lib542.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib543 "$LIBTEST_DIR"/lib543.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib544 "$LIBTEST_DIR"/lib544.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib545 "$LIBTEST_DIR"/lib544.c "$SUPPORTFILES" -DLIB545
${CC} -o "$DEST_DIR"/lib547 "$LIBTEST_DIR"/lib547.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib548 "$LIBTEST_DIR"/lib547.c "$SUPPORTFILES" -DLIB548
${CC} -o "$DEST_DIR"/lib549 "$LIBTEST_DIR"/lib549.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib552 "$LIBTEST_DIR"/lib552.c "$SUPPORTFILES" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib553 "$LIBTEST_DIR"/lib553.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib554 "$LIBTEST_DIR"/lib554.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib555 "$LIBTEST_DIR"/lib555.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib556 "$LIBTEST_DIR"/lib556.c "$SUPPORTFILES" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib557 "$LIBTEST_DIR"/lib557.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib558 "$LIBTEST_DIR"/lib558.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib560 "$LIBTEST_DIR"/lib560.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib562 "$LIBTEST_DIR"/lib562.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib564 "$LIBTEST_DIR"/lib564.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib565 "$LIBTEST_DIR"/lib510.c "$SUPPORTFILES" -DLIB565
${CC} -o "$DEST_DIR"/lib566 "$LIBTEST_DIR"/lib566.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib567 "$LIBTEST_DIR"/lib567.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib568 "$LIBTEST_DIR"/lib568.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib569 "$LIBTEST_DIR"/lib569.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib570 "$LIBTEST_DIR"/lib570.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib571 "$LIBTEST_DIR"/lib571.c "$SUPPORTFILES" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib572 "$LIBTEST_DIR"/lib572.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib573 "$LIBTEST_DIR"/lib573.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" "$TSTTRACE"
${CC} -o "$DEST_DIR"/lib574 "$LIBTEST_DIR"/lib574.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib575 "$LIBTEST_DIR"/lib575.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib576 "$LIBTEST_DIR"/lib576.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib578 "$LIBTEST_DIR"/lib578.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib579 "$LIBTEST_DIR"/lib579.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib582 "$LIBTEST_DIR"/lib582.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib583 "$LIBTEST_DIR"/lib583.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib585 "$LIBTEST_DIR"/lib500.c "$SUPPORTFILES" "$TESTUTIL" "$TSTTRACE" -DLIB585
${CC} -o "$DEST_DIR"/lib586 "$LIBTEST_DIR"/lib586.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib587 "$LIBTEST_DIR"/lib554.c "$SUPPORTFILES" -DLIB587
${CC} -o "$DEST_DIR"/lib590 "$LIBTEST_DIR"/lib590.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib591 "$LIBTEST_DIR"/lib591.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib597 "$LIBTEST_DIR"/lib597.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib598 "$LIBTEST_DIR"/lib598.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib599 "$LIBTEST_DIR"/lib599.c "$SUPPORTFILES"
${CC} -o "$DEST_DIR"/lib1500 "$LIBTEST_DIR"/lib1500.c "$SUPPORTFILES" "$TESTUTIL"
${CC} -o "$DEST_DIR"/lib1501 "$LIBTEST_DIR"/lib1501.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib1502 "$LIBTEST_DIR"/lib1502.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1502
${CC} -o "$DEST_DIR"/lib1503 "$LIBTEST_DIR"/lib1502.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1503
${CC} -o "$DEST_DIR"/lib1504 "$LIBTEST_DIR"/lib1502.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1504
${CC} -o "$DEST_DIR"/lib1505 "$LIBTEST_DIR"/lib1502.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1505
${CC} -o "$DEST_DIR"/lib1506 "$LIBTEST_DIR"/lib1506.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1506
${CC} -o "$DEST_DIR"/lib1507 "$LIBTEST_DIR"/lib1507.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1507
${CC} -o "$DEST_DIR"/lib1508 "$LIBTEST_DIR"/lib1508.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1508
${CC} -o "$DEST_DIR"/lib1509 "$LIBTEST_DIR"/lib1509.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1509
${CC} -o "$DEST_DIR"/lib1510 "$LIBTEST_DIR"/lib1510.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1510
${CC} -o "$DEST_DIR"/lib1511 "$LIBTEST_DIR"/lib1511.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1511
${CC} -o "$DEST_DIR"/lib1512 "$LIBTEST_DIR"/lib1512.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1512
${CC} -o "$DEST_DIR"/lib1513 "$LIBTEST_DIR"/lib1513.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1513
${CC} -o "$DEST_DIR"/lib1514 "$LIBTEST_DIR"/lib1514.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1514
${CC} -o "$DEST_DIR"/lib1515 "$LIBTEST_DIR"/lib1515.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1515
${CC} -o "$DEST_DIR"/lib1520 "$LIBTEST_DIR"/lib1520.c "$SUPPORTFILES" -DLIB1520
${CC} -o "$DEST_DIR"/lib1525 "$LIBTEST_DIR"/lib1525.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1525
${CC} -o "$DEST_DIR"/lib1526 "$LIBTEST_DIR"/lib1526.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1526
${CC} -o "$DEST_DIR"/lib1527 "$LIBTEST_DIR"/lib1527.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1527
${CC} -o "$DEST_DIR"/lib1528 "$LIBTEST_DIR"/lib1528.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1528
${CC} -o "$DEST_DIR"/lib1529 "$LIBTEST_DIR"/lib1529.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1529
${CC} -o "$DEST_DIR"/lib1530 "$LIBTEST_DIR"/lib1530.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DLIB1530
${CC} -o "$DEST_DIR"/lib1900 "$LIBTEST_DIR"/lib1900.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS"
${CC} -o "$DEST_DIR"/lib2033 "$LIBTEST_DIR"/libntlmconnect.c "$SUPPORTFILES" "$TESTUTIL" "$WARNLESS" -DUSE_PIPELINING

mkdir -p "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests/libtest
install -m 0755 "$DEST_DIR"/* "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests/libtest

# symlinks so runtests.pl can find them
install -d -m 0755 "$INSTALL_DIR"/usr/local/share/bsdtests/curl/src
ln -s /usr/bin/curl "$INSTALL_DIR"/usr/local/share/bsdtests/curl/src
ln -s /usr/bin/curl-config "$INSTALL_DIR"/usr/local/share/bsdtests/curl

# perl scripts and modules
install -m 0644 "$PROJECT_DIR"/curl/tests/*.p[lm] "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests
install -m 0755 "$PROJECT_DIR"/curl/tests/libtest/*.pl "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests/libtest

# install data files
# Makefile.am is enough to run `cd data && make show` as runtests.pl expects
install -d -m 0755 "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests/data
install -m 0644 "$PROJECT_DIR"/curl/tests/data/Makefile.am "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests/data/Makefile
install -m 0644 "$PROJECT_DIR"/curl/tests/data/Makefile.inc "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests/data
install -m 0644 "$PROJECT_DIR"/curl/tests/data/test* "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests/data
install -m 0644 "$PROJECT_DIR"/curl/tests/data/DISABLED "$INSTALL_DIR"/usr/local/share/bsdtests/curl/tests/data

install -d -m 0755 "$INSTALL_DIR"/usr/local/share/bsdtests/curl/docs/libcurl
install -m 0644 "$PROJECT_DIR"/curl/docs/libcurl/symbols-in-versions "$INSTALL_DIR"/usr/local/share/bsdtests/curl/docs/libcurl

install -d -m 0755 "$INSTALL_DIR"/usr/local/share/bsdtests/curl/include
ln -s /usr/include/curl "$INSTALL_DIR"/usr/local/share/bsdtests/curl/include

install -d -m 0755 "$INSTALL_DIR"/usr/local/share/bsdtests/curl/lib
install -m 0755 "$LIB_DIR"/objnames-test*.sh "$INSTALL_DIR"/usr/local/share/bsdtests/curl/lib
install -m 0644 "$LIB_DIR"/objnames.inc "$INSTALL_DIR"/usr/local/share/bsdtests/curl/lib
