#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>

#include "../helpers/test_helpers.hpp"

template <typename T, int N, int Offset, bool ForceRuntime = false>
constexpr auto any_of_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";

  std::array<T, N> arr {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = (i + 1) * Offset;
  
  // the input and output probably can't alias
  bool t1 = std::any_of(arr.begin(), arr.end(), 
                        [](auto i){ return (i % 2 == 0); });
  
  bool t2 = std::any_of(arr.begin(), arr.end(), 
                        [](auto i){ return (i % 2 == 1); });
  
  return (t1 == true && t2 == false);
}

int main() {
  constexpr auto output_ov1 = any_of_ov1<int, 32, 2>();
  auto runtime_ov1 = any_of_ov1<int, 32, 2, true>();
  
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
  
  return 0;
}
