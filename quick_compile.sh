#!/bin/bash

mkdir -p build
cd build
cmake -DDEBUG=ON -DSHARED_LIB=ON ..
# cmake -DDEBUG=ON -DSHARED_LIB=ON -DTESTING=ON ..
make
cd ..
