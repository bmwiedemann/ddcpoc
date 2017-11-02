#!/bin/sh -e
dir=tcc-0.9.26
run=1 ./buildonce.sh
export CC=$PWD/tcc.1/bin/tcc
run=2 ./buildonce.sh
