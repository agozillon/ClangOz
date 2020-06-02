#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>

#include "../helpers/test_helpers.hpp"

/*
  The adjacent_find from the libcxx library works with while loops, it might be
  feasible to use our algorithm with while loops like shown in adjacent_find, 
  but it may also just be a lot easier to write our own adjacent_find algorithm
  that uses a for loop like the one shown below from cppreference (although
  this version doesn't quite work either at the moment):
*/

/*
template<class ForwardIt>
constexpr ForwardIt adjacent_find(ForwardIt first, ForwardIt last)
{
    if (first == last) {
        return last;
    }
    ForwardIt next = first;
    ++next;
    for (; next != last; ++next, ++first) {
        if (*first == *next) {
            return first;
        }
    }
    return last;
}
*/
template <typename T, int N, bool ForceRuntime = false>
constexpr auto adjacent_find_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";

  std::array<T, N> arr {};

  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;

  // Test if works normally, then test if it works even with elements split 
  // across threads
  arr[8] = 8;
  arr[9] = 8;
  
  auto found = std::adjacent_find(arr.begin(), arr.end());
  
  return std::distance(arr.begin(), found);
}

int main() {
  constexpr auto output_ov1 = adjacent_find_ov1<int, 32>();
  auto runtime_ov1 = adjacent_find_ov1<int, 32, true>();

  std::cout << output_ov1 << "\n";
  
  std::cout << "\n\n\n";
  
  std::cout << runtime_ov1 << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
