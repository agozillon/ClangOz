#include <array>
#include <numeric>
#include <iostream>
#include <type_traits>
#include <cassert>

#include "../helpers/test_helpers.hpp"

/* Not working at the moment, the underlying issue may be similar to adjacent 
  difference, perhaps adjacent elements in the thread argument list need to be
  copied to prevent overwrites / race conditions */

template <typename T, int N, int Offset, bool ForceRuntime = false>
constexpr auto partial_sum_ov1() {
  if constexpr (ForceRuntime)
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";

  std::array<T, N> arr {};
  std::array<T, N> out {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = (i + 1) * Offset;
  
  // the input and output probably can't alias
  std::partial_sum(arr.begin(), arr.end(), out.begin());
  
  return out;
}

template <typename T, int N, int Offset, bool ForceRuntime = false>
constexpr auto partial_sum_ov2() {
  if constexpr (ForceRuntime)
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";
    
  std::array<T, N> arr {};
  std::array<T, N> out {};
  
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = (i + 1) * Offset;
  
  // the input and output probably can't alias
  std::partial_sum(arr.begin(), arr.end(), 
                   out.begin(), std::plus<>{});
  
  return out;
}

int main() {
  constexpr auto output_ov1 = partial_sum_ov1<int, 32, 2>();
  
  pce::utility::print_arr(output_ov1);
  
  constexpr auto output_ov2 = partial_sum_ov2<int, 32, 2>();
  
  pce::utility::print_arr(output_ov2);

  auto runtime_ov1 = partial_sum_ov1<int, 32, 2, true>();
  auto runtime_ov2 = partial_sum_ov2<int, 32, 2, true>();
  
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov2, runtime_ov2)
    << "\n";
  
  return 0;
}
