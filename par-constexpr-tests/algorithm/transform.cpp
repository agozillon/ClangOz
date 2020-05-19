#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>

#include "../helpers/test_helpers.hpp"

// There appears to be a race condition in transform that only occurs every few
// compilations

template <typename T, int N, bool ForceRuntime = false>
constexpr auto transform_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";

    std::array<T, N> a = {0};
    std::array<T, N> b = {0};
    std::array<T, N> c = {0};
  
    for (int i = 0; i < c.size(); ++i)
      a[i] = b[i] = (i + 1);
    
    std::transform(std::begin(a), std::end(a), 
                   std::begin(b), std::begin(c), 
                   std::plus<T>());

   return c; 
}

int main() {
  constexpr auto output_ov1 = transform_ov1<int, 32>();
  auto runtime_ov1 = transform_ov1<int, 32, true>();
  
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
  /*
  for (auto ov : runtime_ov1)
    std::cout << ov << "\n";
        
  std::cout << "\n\n\n";
  
  for (auto ov : output_ov1)
    std::cout << ov << "\n";
    */
  
  return 0;
}
