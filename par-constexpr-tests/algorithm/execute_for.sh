#!/bin/bash

usage() { echo $0: error: $2 >&2; exit $1; }

if [[ -z "$1" ]]; then
  usage 1 "no execution count parameter"
fi

if [[ -z "$2" ]]; then
  usage 2 "no file to compile and execute"
fi

EXECUTE_COUNT="$1"
FILE="$2"

for ((i=0; i<=EXECUTE_COUNT; i++)); do
  $CLANG_BIN/clang++ -fconstexpr-steps=2147483647 -std=c++2a -stdlib=libc++ \
    -fexperimental-constexpr-parallel $FILE -o $FILE.out && ./$FILE.out 
done

#rm $FILE.out
