#!/bin/bash

git submodule update --init --recursive

pushd Dependencies/ios_system
./get_sources.sh
./get_frameworks.sh

popd

./resign-frameworks.sh
