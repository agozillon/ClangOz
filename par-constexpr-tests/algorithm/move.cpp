#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

constexpr int arr_sz = 32;
using arr_t = int;

template <typename T, int N, bool ForceRuntime = false>
constexpr auto move_ov1(auto& arr) {
  std::array<T, N> arr_move {};

  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    std::move(arr.begin(), arr.end(), arr_move.begin());
  } else {
    std::move(execution::ce_par, arr.begin(), arr.end(), arr_move.begin());
  }
  
  return arr_move;
}

consteval auto arr_gen() {
  std::array<arr_t, arr_sz> arr {};
  
  for (int i = 0; i < arr_sz; ++i)
    arr[i] = i;
    
  return arr;
}

int main() {

  constexpr auto arr = arr_gen();
  constexpr auto arr2 = arr_gen();

  constexpr auto output_ov1 = move_ov1<arr_t, arr_sz>(arr);
  auto runtime_ov1 = move_ov1<arr_t, arr_sz, true>(arr2);

//  for (auto r : runtime_ov1)
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : output_ov1)
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : arr)
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : arr2)
//    std::cout << r << "\n";
    
  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
     && pce::utility::check_runtime_against_compile(arr, arr2))
    << "\n";

  return 0;
}
