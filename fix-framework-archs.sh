#!/bin/bash

lipo -remove i386 Dependencies/ios_system/Frameworks/openssl.framework/openssl -o Dependencies/ios_system/Frameworks/openssl.framework/openssl
lipo -remove x86_64 Dependencies/ios_system/Frameworks/openssl.framework/openssl -o Dependencies/ios_system/Frameworks/openssl.framework/openssl

lipo -remove i386 Dependencies/ios_system/Frameworks/libssh2.framework/libssh2 -o Dependencies/ios_system/Frameworks/libssh2.framework/libssh2
lipo -remove x86_64 Dependencies/ios_system/Frameworks/libssh2.framework/libssh2 -o Dependencies/ios_system/Frameworks/libssh2.framework/libssh2