#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>
#include <functional>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"


template <typename T, int N, bool ForceRuntime = false>
constexpr auto replace_if_ov1() {
  std::array<T, N> arr {};

  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;

  auto less_than_15 = [](auto v) { 
    if (v < 15) 
      return true; 
    else 
      return false;
  };
                                        
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    std::replace_if(arr.begin(), arr.end(), less_than_15, 42);
  } else {
    std::replace_if(execution::ce_par, arr.begin(), arr.end(), less_than_15, 
                    42);
  }
  
  return arr;
}

int main() {
  constexpr auto output_ov1 = replace_if_ov1<int, 32>();
  auto runtime_ov1 = replace_if_ov1<int, 32, true>();

//  for (auto r : runtime_ov1)
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : output_ov1)
//    std::cout << r << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
