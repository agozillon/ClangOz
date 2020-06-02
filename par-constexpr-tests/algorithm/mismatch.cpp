#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>

#include "../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto mismatch_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";

  std::array<T, N> arr {};
  std::array<T, N> arr2 {}; 
  
  for (int i = 0; i < arr.size(); ++i)
   arr2[i] = arr[i] = i;

  arr2[13] = static_cast<T>(101);
  arr2[31] = static_cast<T>(111);
  
  auto ret = std::mismatch(arr.begin(), arr.end(), arr2.begin());
  
  // returns an iterator, need to convert it to values to return it from this 
  // function as we rightfully cannot return a pair of iterators pointing to a
  // subobject of something created at compile time that dies in the scope of a
  // constexpr function.
  return std::pair<T,T>(*ret.first, *ret.second);
}

int main() {
  constexpr auto output_ov1 = mismatch_ov1<int, 32>();
  auto runtime_ov1 = mismatch_ov1<int, 32, true>();

  // maybe make an overloaded print function similar to the check function.. 
  std::cout << runtime_ov1.first << " " << runtime_ov1.second << "\n";
  
  std::cout << "\n\n\n";
  
  std::cout << output_ov1.first << " " << output_ov1.second << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
 
  return 0;
}
