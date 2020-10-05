#!/bin/bash

function constexpr_execute {
  echo "Executing Test: $1 "
  echo " "
  echo " "
  echo " "
  $CLANGOZ/bin/clang++ -fconstexpr-steps=4294967295 -std=c++2a -stdlib=libc++ \
    -I$CEST_INCLUDE -fexperimental-constexpr-parallel $1 -o $1.out && ./$1.out
  echo " "
  echo " "
  echo " "
  echo "End Executing Test: $1 "
}


# 25 passes
constexpr_execute all_of.cpp
constexpr_execute any_of.cpp
constexpr_execute none_of.cpp
constexpr_execute copy.cpp 
constexpr_execute copy_backward.cpp
constexpr_execute copy_n.cpp 
constexpr_execute move.cpp
constexpr_execute move_backward.cpp
constexpr_execute count.cpp
constexpr_execute count_if.cpp
constexpr_execute find.cpp
constexpr_execute find_first_of.cpp
constexpr_execute find_if.cpp
constexpr_execute find_if_not.cpp
constexpr_execute for_each.cpp
constexpr_execute for_each_n.cpp
constexpr_execute mismatch.cpp
#constexpr_execute set_intersection.cpp # currently broken, crashes when using a static vec 
                                        # and doesn't quite work when using an array either
                                        # needs a fix
constexpr_execute transform.cpp
constexpr_execute fill.cpp
constexpr_execute fill_n.cpp
constexpr_execute replace.cpp
constexpr_execute replace_if.cpp
constexpr_execute replace_copy.cpp
constexpr_execute replace_copy_if.cpp
#constexpr_execute iter_swap.cpp # doesn't work
constexpr_execute swap_ranges.cpp
constexpr_execute is_partitioned.cpp
constexpr_execute is_sorted.cpp
constexpr_execute is_sorted_until.cpp
#constexpr_execute lexicographical_compare.cpp # I broke this somehow, need to look into it at some point
