#include <array>
#include <algorithm>
#include <iostream>
#include <numeric>
#include <iterator>

template <typename T, int N>
consteval auto multiply_by_2_array() {
  std::array<T, N> a = {0};
  std::iota(a.begin(), a.end(), 0);
  std::for_each(a.begin(), a.end(), [](auto &i){ i *= 2; });
  return a;
}

// Simple test aiming to see if numbers indivisable by a power of 2 set of cores
// can correctly be partitioned by the compiler
int main() {
  // overflow of 1 when running on 4 cores
  constexpr auto arr = multiply_by_2_array<double, 129>(); 
  // overflow of 2 when running on 4 cores
  constexpr auto arr2 = multiply_by_2_array<float, 311134>(); 

  // runtime comparison checks
  bool arr_correct = true;
  for (int i = 0; i < arr.size(); ++i) {
    if (arr[i] != i*2)
      arr_correct = false;
  }

  bool arr2_correct = true;
  for (int i = 0; i < arr2.size(); ++i) {
    if (arr2[i] != i*2)
      arr2_correct = false;
  }
 
  int result = (arr2_correct & arr_correct) ? 0 : -1; 
  
  std::cout << "runtime output correct? " << (result == 0) << "\n";
  
  return result;
}
