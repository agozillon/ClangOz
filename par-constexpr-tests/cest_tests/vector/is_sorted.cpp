#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false, bool Unsorted = false>
constexpr auto is_sorted_ov1() {
  cest::vector<int> vec {};

  if constexpr (Unsorted) { // default uses < than, so it's "unsorted"
    for (int i = 0; i < N; ++i)
      vec.push_back(N - i);
  } else {
    for (int i = 0; i < N; ++i)
      vec.push_back(i);
  }

  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
   return std::is_sorted(vec.begin(), vec.end());
  } else {
   return std::is_sorted(execution::ce_par, vec.begin(), vec.end());
  }

}

int main() {
  constexpr auto output_ov1 = is_sorted_ov1<int, 32>();
  auto runtime_ov1 = is_sorted_ov1<int, 32, true>();

  constexpr auto output_unsorted_ov1 = is_sorted_ov1<int, 32, false, true>();
  auto runtime_unsorted_ov1 = is_sorted_ov1<int, 32, true, true>();

//  for (auto r : runtime_ov1)
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : output_ov1)
//    std::cout << r << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1) &&
       pce::utility::check_runtime_against_compile(output_unsorted_ov1, 
                                                   runtime_unsorted_ov1))
    << "\n";

  return 0;
}
