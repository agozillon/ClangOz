#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>

#include "../helpers/test_helpers.hpp"

  
template <typename T, int N, bool ForceRuntime = false>
constexpr auto find_if_not_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";

  std::array<T, N> arr {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;

  auto found = std::find_if_not(arr.begin(), arr.end(), 
                                [](auto i){ return i == 0; });
  
  return *found;
}

int main() {
  constexpr auto output_ov1 = find_if_not_ov1<int, 32>();
  auto runtime_ov1 = find_if_not_ov1<int, 32, true>();

  std::cout << output_ov1 << "\n";
  
  std::cout << "\n\n\n";
  
  std::cout << runtime_ov1 << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
