#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto find_ov1() {
  std::array<T, N> arr {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;

  int* found; 
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    found = std::find(arr.begin(), arr.end(), 27);
  } else {
    // Note: a little interesting thing about this test is that it will try to 
    // compute the results of std::find twice and fail the first time. It 
    // appears to be because of the return value, it's checking it for overflow.
    // This unfortunately means some small little caveats might occur in the 
    // first pass that don't occur in the second.
    found = std::find(execution::ce_par, arr.begin(), arr.end(), 27);
  }
  
  return *found;
}

int main() {
  constexpr auto output_ov1 = find_ov1<int, 32>();
  auto runtime_ov1 = find_ov1<int, 32, true>();

  std::cout << output_ov1 << "\n";
  
  std::cout << "\n\n\n";
  
  std::cout << runtime_ov1 << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
