#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto replace_ov1() {
  cest::vector<int> vec{};

  for (int i = 0; i < N; ++i)
    vec.push_back(i);

  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    std::replace(vec.begin(), vec.end(), 8, 88);
  } else {
    std::replace(execution::ce_par, vec.begin(), vec.end(), 8, 88);
  }
  
  return pce::utility::convert_container_to_array<T, N>(vec);
}

int main() {
  constexpr auto output_ov1 = replace_ov1<int, 32>();
  auto runtime_ov1 = replace_ov1<int, 32, true>();

//  for (auto r : runtime_ov1)
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : output_ov1)
//    std::cout << r << "\n";
//      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
