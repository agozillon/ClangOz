#include <array>
#include <numeric>
#include <iostream>
#include <type_traits>
#include <execution>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto iota_ov1() {
  std::array<T, N> arr {};
  
    // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    std::iota(arr.begin(), arr.end(), 0);
  } else {
    std::iota(execution::ce_par, arr.begin(), arr.end(), 0);
  }
  
  return arr;
}


int main() {
  constexpr auto output_ov1 = iota_ov1<int, 32>();
  auto runtime_ov1 = iota_ov1<int, 32, true>();
  
  for (auto arr : output_ov1) {
    std::cout << arr << "\n";
  }
  
  std::cout << "\n\n\n";
  
  for (auto arr : runtime_ov1) {
    std::cout << arr << "\n";
  }
  
    std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
  
  return 0;
}
