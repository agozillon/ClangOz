#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>

#include "../helpers/test_helpers.hpp"

/*
  Not working, copies out of/in a random order as they race to write to the 
  first segment of the array.
  
  This and the lock may be removal by creating copies of the writen to array
  and then "reducing" it. Need to think about this one a bit more. 
*/

template <typename T, int N, bool ForceRuntime = false>
constexpr auto for_each_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";

  std::array<T, N> arr {};
  std::array<T, N> arr_copy {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;

  std::copy_if(arr.begin(), arr.end(), arr_copy.begin(), 
               [](auto i) { return i % 2 == 0; });
  
  return arr_copy;
}

int main() {
  constexpr auto output_ov1 = for_each_ov1<int, 32>();
  auto runtime_ov1 = for_each_ov1<int, 32, true>();

  for (auto r : runtime_ov1)
    std::cout << r << "\n";
  
  std::cout << "\n\n\n";
  
  for (auto r : output_ov1)
    std::cout << r << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
