#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

// The set_intersection benchmark is a little rng because you can generate much 
// smaller numbers of intersections based on the seed... need to create a fixed
// seed and try again.

// Fix Fill
// Fix copy_if

template <typename T, int N, bool ForceRuntime = false>
constexpr auto fill_ov1() {
  std::array<T, N> arr {};
    

  if constexpr (ForceRuntime) { 
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    std::fill(arr.begin(), arr.end(), -1);
  } else {
    std::fill(execution::ce_par, arr.begin(), arr.end(), -1);
  }
  
  return arr;
}

int main() {
  constexpr auto output_ov1 = fill_ov1<int, 32>();
  auto runtime_ov1 = fill_ov1<int, 32, true>();
  
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
    
  return 0;
}
