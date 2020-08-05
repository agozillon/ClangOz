#!/bin/bash

function constexpr_execute {
  echo "Executing Test: $1 "
  echo " "
  echo " "
  echo " "
  $CLANG_BIN/clang++ -fconstexpr-steps=2147483647 -std=c++2a -stdlib=libc++ \
    -fexperimental-constexpr-parallel $1 -o $1.out && ./$1.out
  echo " "
  echo " "
  echo " "
  echo "End Executing Test: $1 "
}

# 19 passes
constexpr_execute all_of.cpp
constexpr_execute any_of.cpp
constexpr_execute copy.cpp
# constexpr_execute copy_if.cpp # doesn't work
constexpr_execute copy_n.cpp
constexpr_execute count.cpp
constexpr_execute count_if.cpp
constexpr_execute find.cpp
constexpr_execute find_end.cpp
constexpr_execute find_first_of.cpp
constexpr_execute find_if.cpp
constexpr_execute find_if_not.cpp
constexpr_execute for_each.cpp
constexpr_execute for_each_n.cpp
constexpr_execute mismatch.cpp
constexpr_execute none_of.cpp
constexpr_execute set_intersection.cpp
constexpr_execute transform.cpp
constexpr_execute fill.cpp
constexpr_execute fill_n.cpp
