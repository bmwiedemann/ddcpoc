#!/bin/sh -e
dir=tcc-0.9.26
run=1 ./buildonce.sh
rm -rf $dir.1
mv $dir $dir.1
export CC=$PWD/tcc.1/bin/tcc
run=2 ./buildonce.sh
