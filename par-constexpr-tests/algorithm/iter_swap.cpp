#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>
#include <functional>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

constexpr int arr_sz = 32;
using arr_t = int;

template <typename T, int N, bool ForceRuntime = false>
constexpr auto iter_swap_ov1() {
  std::array<T[N], N> arr_swap {};
  std::array<T[N], N> arr {};
  
  for (int i = 0; i < N; ++i)
    for (int j = 0; j < N; ++j)
    arr[i][j] = j;
    
  for (int i = 0; i < N; ++i)
    for (int j = 0; j < N; ++j)
    arr_swap[i][j] = N + j;
    
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    std::iter_swap(arr.begin(), arr_swap.begin());
  } else {
    std::iter_swap(execution::ce_par, arr.begin(), arr_swap.begin());
  }
  
  return std::pair<std::array<T[N], N>,  
                   std::array<T[N], N>>(arr, arr_swap);
}


// Investigate for an hour but dont commit too much time, this function isn't
// important, it may be the way the algorithm currently partitions 2d/multidimensional
// arrays.
int main() {
  constexpr auto output_ov1 = iter_swap_ov1<arr_t, arr_sz>();
  auto runtime_ov1 = iter_swap_ov1<arr_t, arr_sz, true>();


  bool first = true;
  for (int i = 0; i < arr_sz; ++i) 
     for (int j = 0; j < arr_sz; ++j)
      if (std::get<0>(output_ov1)[i][j] != std::get<0>(runtime_ov1)[i][j]) {
        first = false;
        break;
      }     
  std::cout << first << "\n";
  bool second = true;
  for (int i = 0; i < arr_sz; ++i) 
     for (int j = 0; j < arr_sz; ++j)
      if (std::get<1>(output_ov1)[i][j] != std::get<1>(runtime_ov1)[i][j]) {
        second = false;
        break;
      }
      std::cout << second << "\n";
  std::cout << "Runtime == Compile Time: " << (first && second) << "\n";

  return 0;
}
