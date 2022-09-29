#!/bin/bash

git clone https://github.com/marcusspangenberg/SymphonyMediaBridge.git
pushd SymphonyMediaBridge
git checkout marcus/fix_broken_outbound_cleanup
CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" .
CC=clang CXX=clang++ make -j5
popd
