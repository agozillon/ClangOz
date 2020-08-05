#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <iterator>
#include <execution>
#include <random>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"


template <typename T, int N, bool ForceRuntime = false>
constexpr auto set_intersection_ov1(auto intersection_arr) {
  std::array<T, N> out {}; // would be better as a vector, but no constexpr 
                          // vector yet in the std library
  std::array<T, N> arr {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;
    
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    std::set_intersection(arr.begin(), arr.end(), intersection_arr.begin(), 
                          intersection_arr.end(), out.begin());
  } else {
    std::set_intersection(execution::ce_par, arr.begin(), arr.end(), 
                          intersection_arr.begin(), intersection_arr.end(), 
                          out.begin());
  }
  
   return out; 
}

template <typename T, int Sz, int Max>
consteval auto rnd_arry() {
  auto tmp = pce::utility::generate_array_within_range<T, Sz>(0, Max);
  pce::utility::quick_sort(begin(tmp), end(tmp));
  auto arr = pce::utility::remove_dups_from_sorted<T, Sz>(tmp);
  return arr;
}

template <typename T>
constexpr bool compare_vals(auto arr, auto arr2) {
  pce::utility::quick_sort(begin(arr), end(arr));
  pce::utility::quick_sort(begin(arr2), end(arr2));
  // all this really does is push all 0's to the back, so its not full proof
  auto tmp = pce::utility::remove_dups_from_sorted<T, arr.size()>(arr);
  auto tmp2 = pce::utility::remove_dups_from_sorted<T, arr2.size()>(arr2);

  size_t max = (tmp.size() > tmp2.size()) ? tmp2.size() : tmp.size();

  for (int i = 0; i < max; i++) {  
    if (tmp[i] != tmp2[i])
      return false;
  }
  
  return true;
}

int main() {
  constexpr auto intersection_arr = rnd_arry<int, 16, 31>();
  
//  for (int i = 0; i < intersection_arr.size(); ++i) {
//    std::cout << intersection_arr[i] << " ";
//  }
  
  constexpr auto output_ov1 = set_intersection_ov1<int, 32>(intersection_arr);
  auto runtime_ov1 = set_intersection_ov1<int, 32, true>(intersection_arr);

  constexpr bool b1 = compare_vals<int>(intersection_arr, output_ov1);
  bool b2 = compare_vals<int>(intersection_arr, runtime_ov1);

  std::cout << "runtime & compile time intersection list equal " << (b1 & b2) << "\n";

  for (int i = 0; i < 32; ++i) {
    std::cout << output_ov1[i] << " ";
  }
  
  std::cout << "\n\n\n";
  
  for (int i = 0; i < 32; ++i) {
    std::cout << runtime_ov1[i] << " ";
  }
    std::cout << "\n\n\n";
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
  
  return 0;
}
