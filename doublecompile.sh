#!/bin/sh -e
run=1 ./buildonce.sh
export CC=$PWD/tcc.1/bin/tcc
run=2 ./buildonce.sh
