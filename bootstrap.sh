#!/bin/bash

git submodule update --init --recursive

pushd Dependencies/ios_system
./get_sources.sh
./get_frameworks_fat.sh
popd

pushd Dependencies/network_ios
./get_frameworks.sh
popd
