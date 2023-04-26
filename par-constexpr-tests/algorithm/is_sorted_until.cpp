#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false, bool Unsorted = false>
constexpr auto is_sorted_until_ov1() {
  std::array<T, N> arr {};

  if constexpr (Unsorted) { // default uses < than, so it's "unsorted"
    for (int i = 0; i < arr.size(); ++i)
      arr[i] = arr.size() - i;
  } else {
    for (int i = 0; i < arr.size(); ++i)
      arr[i] = i;
  }

  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    auto v = std::is_sorted_until(arr.begin(), arr.end());
    if (v != arr.end())
       return *v;
     else 
       return -1;
  } else {
    auto v = std::is_sorted_until(execution::ce_par, arr.begin(), arr.end());
    if (v != arr.end())
      return *v;
    else 
      return -1;
  }

}

int main() {
  constexpr auto output_ov1 = is_sorted_until_ov1<int, 32>();
  auto runtime_ov1 = is_sorted_until_ov1<int, 32, true>();

  constexpr auto output_unsorted_ov1 = is_sorted_until_ov1<int, 32, false, 
                                                           true>();
  auto runtime_unsorted_ov1 = is_sorted_until_ov1<int, 32, true, true>();

  // should be 31 is... 23?
  std::cout << output_unsorted_ov1 << " vs " << runtime_unsorted_ov1 << "\n";
  std::cout << output_ov1 << " vs " << runtime_ov1 << "\n";

  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1) &&
       pce::utility::check_runtime_against_compile(output_unsorted_ov1, 
                                                   runtime_unsorted_ov1))
    << "\n";

  return 0;
}
