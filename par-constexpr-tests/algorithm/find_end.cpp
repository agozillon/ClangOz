#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>

#include "../helpers/test_helpers.hpp"


// Won't work in current libc++ implementation, implemented using 
// while loops which we don't currently cover (only for stmts for now),
// it's also a series of while loops with no end condition (set to 
// infinitely loop via true condition). The end conditions are internally 
// represented in the loop as breaks/returns, this would require a lot
// more code analysis than really seems feasible at the moment.
//
// It may be possible to rewrite it as a simpler function with clear condiitons
// to parallelize it from, which could allow it to be parallizeable even if its
// technically slower when serial. The nature of the function may prevent it 
// though.


template <typename T, int N, bool ForceRuntime = false>
constexpr auto find_end_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";

  std::array<T, N> arr {};
  std::array<T, 4> seq {0,1,2,3};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i % 4;

  auto found = std::find_end(arr.begin(), arr.end(), 
                             seq.begin(), seq.end());
  
  return std::distance(arr.begin(), found);
}

int main() {
  constexpr auto output_ov1 = find_end_ov1<int, 32>();
  auto runtime_ov1 = find_end_ov1<int, 32, true>();

  std::cout << output_ov1 << "\n";
  
  std::cout << "\n\n\n";
  
  std::cout << runtime_ov1 << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
