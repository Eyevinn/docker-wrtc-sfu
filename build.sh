#!/bin/bash

git clone https://github.com/marcusspangenberg/SymphonyMediaBridge.git
pushd SymphonyMediaBridge
git checkout 953ae35f6c3b276a40bcc45dbe4fb4b961c9bfec
CC=clang CXX=clang++ cmake -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" .
CC=clang CXX=clang++ make -j5
popd
