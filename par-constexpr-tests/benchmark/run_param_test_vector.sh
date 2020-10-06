#!/bin/bash

for i in 1024 2048 4096 8192 16384 32768 65536; do
  echo
  echo "### " $i "-fexperimental-constexpr-parallel OFF"
  for j in 1 2 3 ; do
    time $CLANGOZ/bin/clang++ -I $CEST_INCLUDE -fconstexpr-steps=4294967295 -std=c++2a -stdlib=libc++                                   param_test.cpp -DSZ=$i
  done

  echo
  echo "### " $i "-fexperimental-constexpr-parallel ON"
  for j in 1 2 3 ; do
    time $CLANGOZ/bin/clang++ -I $CEST_INCLUDE -fconstexpr-steps=4294967295 -std=c++2a -stdlib=libc++ -fexperimental-constexpr-parallel param_test.cpp -DSZ=$i
  done
done


