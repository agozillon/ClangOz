#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>
#include <functional>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"


template <typename T, int N, bool ForceRuntime = false>
constexpr auto replace_ov1() {
  std::array<T, N> arr {};

  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;

  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    std::replace(arr.begin(), arr.end(), 8, 88);
  } else {
    std::replace(execution::ce_par, arr.begin(), arr.end(), 8, 88);
  }
  
  return arr;
}

int main() {
  constexpr auto output_ov1 = replace_ov1<int, 32>();
  auto runtime_ov1 = replace_ov1<int, 32, true>();

//  for (auto r : runtime_ov1)
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : output_ov1)
//    std::cout << r << "\n";
//      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
