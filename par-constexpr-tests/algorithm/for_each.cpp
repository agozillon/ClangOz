#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>

#include "../helpers/test_helpers.hpp"

// There appears to be a race condition in for_each that only occurs every few
// compilations
  
template <typename T, int N, bool ForceRuntime = false>
constexpr auto for_each_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";

  std::array<T, N> arr {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = (i + 32);

  std::for_each(arr.begin(), arr.end(), 
                [](auto &i){ i *= 2; });
  
  return arr;
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
