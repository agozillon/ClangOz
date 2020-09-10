#!/bin/bash

function constexpr_execute {
  echo "Executing Test: $1 "
  echo " "
  echo " "
  echo " "
  $CLANG_BIN/clang++ -fconstexpr-steps=4294967295 -std=c++2a -stdlib=libc++ \
    -I$CEST -fexperimental-constexpr-parallel $1 -o $1.out && ./$1.out
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
# constexpr_execute move_backward.cpp # currently broken
constexpr_execute count.cpp
constexpr_execute count_if.cpp
constexpr_execute find.cpp
constexpr_execute find_first_of.cpp # works but can crash similarly to below, when it should be 
                                    # a simple error message
constexpr_execute find_if.cpp # this will crash the compiler if I change the N to something like 
                              # arr.size() (not even vec.size()! arr isn't even declared), 
                              # this is quite clearly a bug I've added and should be 
                              # fixed
constexpr_execute find_if_not.cpp
constexpr_execute for_each.cpp
constexpr_execute for_each_n.cpp
constexpr_execute mismatch.cpp
#constexpr_execute set_intersection.cpp # currently broken, crashes when using a static vec 
                                        # and doesn't quite work when using an array either
                                        # needs a fix
constexpr_execute transform.cpp
constexpr_execute fill.cpp  # can crash this in copythreadarguments if you do not increase the 
                            # size of the vector appropriately need to fix this
constexpr_execute fill_n.cpp # for some reason we can use reserve in fill, but not in fill_n and transform
                             # instead I have to use a push_back... wonder what the difference is
constexpr_execute replace.cpp
constexpr_execute replace_if.cpp
#constexpr_execute replace_copy.cpp # doesn't work mainly because the requirement for a static constexpr  
                                    # vector which we currently dont handle well, we assert...
#constexpr_execute replace_copy_if.cpp # same reason as above, otherwise works fine (at least with a mix of array and vec)
#constexpr_execute iter_swap.cpp # doesn't work
constexpr_execute swap_ranges.cpp
constexpr_execute is_partitioned.cpp
constexpr_execute is_sorted.cpp
constexpr_execute is_sorted_until.cpp
#constexpr_execute lexicographical_compare.cpp # I broke this somehow, need to look into it at some point
