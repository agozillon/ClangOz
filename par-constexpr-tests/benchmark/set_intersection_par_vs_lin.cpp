#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <iterator>
#include <execution>
#include <random>

// $CLANGOZ/bin/clang++ -fconstexpr-steps=2147483647 -std=c++2a -stdlib=libc++ \
//   -DCONSTEXPR_PAR -fexperimental-constexpr-parallel set_intersection_par_vs_lin.cpp

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

template <typename T, int N>
constexpr auto set_intersection(auto intersection_arr) {
  std::array<T, N> out {};
  std::array<T, N> arr {};
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;
    
#ifdef CONSTEXPR_PAR
    std::set_intersection(execution::ce_par, arr.begin(), arr.end(), 
                          intersection_arr.begin(), intersection_arr.end(), 
                          out.begin());
#else
    std::set_intersection(arr.begin(), arr.end(), intersection_arr.begin(), 
                          intersection_arr.end(), out.begin());
#endif

   return out; 
}

template <typename T, int Sz, int Max>
consteval auto rnd_arry() {
  auto tmp = pce::utility::generate_array_within_range<T, Sz>(0, Max);
  pce::utility::quick_sort(begin(tmp), end(tmp));
  auto arr = pce::utility::remove_dups_from_sorted<T, Sz>(tmp);
  return arr;
}

// see how different the speed is when its not ordered
int main() {
  constexpr auto output = 
      set_intersection<int, 3200000>(rnd_arry<int, 1600000, 3200000>());

  return 0;
}
