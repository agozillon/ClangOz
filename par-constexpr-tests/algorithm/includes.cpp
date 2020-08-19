#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto includes_ov1() {
  std::array<T, N> arr {};
  std::array<T, 4> arr_includes {2,3,4,5};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;

  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    return std::includes(arr.begin(), arr.end(), arr_includes.begin(), 
                         arr_includes.end());
  } else {
    return std::includes(execution::ce_par, arr.begin(), arr.end(), 
                         arr_includes.begin(), arr_includes.end());
  }
}

int main() {
  constexpr auto output_ov1 = includes_ov1<int, 32>();
  auto runtime_ov1 = includes_ov1<int, 32, true>();

  std::cout << output_ov1 << "\n";
  std::cout << runtime_ov1 << "\n";
  
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
