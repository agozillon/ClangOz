#!/bin/bash

function constexpr_execute {
  echo "Executing Test: $1 on $2 threads"
  echo " "
  echo " "
  echo " "
  $CLANGOZ/bin/clang++ -fconstexpr-steps=4294967295 -std=c++2a -stdlib=libc++ \
    -fexperimental-constexpr-parallel -fconstexpr-parallel-partition-size="$2" $1 -o $1.out && ./$1.out
  echo " "
  echo " "
  echo " "
  echo "End Executing Test: $1 on $2 threads"
}

if [[ -z "$1" ]]; then
  USE_THREADS=4
else
  USE_THREADS="$1"
fi

# 29 passes
constexpr_execute all_of.cpp $USE_THREADS
constexpr_execute any_of.cpp $USE_THREADS
constexpr_execute none_of.cpp $USE_THREADS
constexpr_execute copy.cpp $USE_THREADS
constexpr_execute copy_backward.cpp $USE_THREADS
# constexpr_execute copy_if.cpp # doesn't work
constexpr_execute copy_n.cpp $USE_THREADS
constexpr_execute move.cpp $USE_THREADS
constexpr_execute move_backward.cpp $USE_THREADS
constexpr_execute count.cpp $USE_THREADS
constexpr_execute count_if.cpp $USE_THREADS
constexpr_execute find.cpp $USE_THREADS
# constexpr_execute find_end.cpp # doesn't work, very complex rewrite required to make work
constexpr_execute find_first_of.cpp $USE_THREADS
constexpr_execute find_if.cpp $USE_THREADS
constexpr_execute find_if_not.cpp $USE_THREADS
constexpr_execute for_each.cpp $USE_THREADS
constexpr_execute for_each_n.cpp $USE_THREADS
constexpr_execute mismatch.cpp $USE_THREADS
constexpr_execute set_intersection.cpp $USE_THREADS
constexpr_execute transform.cpp $USE_THREADS
constexpr_execute fill.cpp $USE_THREADS
constexpr_execute fill_n.cpp $USE_THREADS
constexpr_execute replace.cpp $USE_THREADS
constexpr_execute replace_if.cpp $USE_THREADS
constexpr_execute replace_copy.cpp $USE_THREADS
constexpr_execute replace_copy_if.cpp $USE_THREADS
#constexpr_execute iter_swap.cpp # doesn't work
constexpr_execute swap_ranges.cpp $USE_THREADS
constexpr_execute is_partitioned.cpp $USE_THREADS
constexpr_execute is_sorted.cpp $USE_THREADS
constexpr_execute is_sorted_until.cpp $USE_THREADS
#constexpr_execute lexicographical_compare.cpp # I broke this somehow, need to look into it at some point
