#!/bin/bash

SMB_VERSION=2.2.0-413

git clone https://github.com/eyevinn/SymphonyMediaBridge.git
pushd SymphonyMediaBridge
git ${SMB_VERSION}
CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" .
CC=clang CXX=clang++ make -j5
popd
