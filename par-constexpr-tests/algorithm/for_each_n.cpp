#include <array>
#include <algorithm>
#include <execution>
#include <iostream>
#include <type_traits>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto for_each_ov1() {
  std::array<T, N> arr {};

  for (int i = 0; i < arr.size(); ++i)
    arr[i] = (i + 32);

    if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";

    std::for_each_n(arr.begin(), 16, [](auto &i){ i *= 2; });
  } else {
    std::for_each_n(execution::ce_par, arr.begin(), 16, 
                    [](auto &i){ i *= 2; });
  }

  return arr;
}

int main() {
  constexpr auto output_ov1 = for_each_ov1<int, 32>();
  auto runtime_ov1 = for_each_ov1<int, 32, true>();

  for (auto r : runtime_ov1)
    std::cout << r << "\n";
  
  std::cout << "\n\n\n";
  
  for (auto r : output_ov1)
    std::cout << r << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
