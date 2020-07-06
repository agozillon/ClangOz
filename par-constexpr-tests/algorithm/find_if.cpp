#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

  
template <typename T, int N, bool ForceRuntime = false>
constexpr auto find_if_ov1() {
  std::array<T, N> arr {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;

  int* found;
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    found = std::find_if(arr.begin(), arr.end(), [](auto i){ return i == 25; });
  } else {
    found = std::find_if(execution::ce_par, arr.begin(), arr.end(), 
                         [](auto i){ return i == 25; });
  }
  
  return *found;
}

int main() {
  constexpr auto output_ov1 = find_if_ov1<int, 32>();
  auto runtime_ov1 = find_if_ov1<int, 32, true>();

  std::cout << output_ov1 << "\n";
  
  std::cout << "\n\n\n";
  
  std::cout << runtime_ov1 << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
