#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto count_ov1() {
  cest::vector<T> vec {};
  
  for (int i = 0; i <  N; ++i)
    vec.push_back(i % 2);

  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  int target = 1, ret;
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    ret = std::count(vec.begin(), vec.end(), target);
  } else {
    ret = std::count(execution::ce_par, vec.begin(), vec.end(), target);
  }

  return ret;
}

int main() {
  constexpr auto output_ov1 = count_ov1<int, 32>();
  auto runtime_ov1 = count_ov1<int, 32, true>();

  std::cout << runtime_ov1 << "\n";
  
  std::cout << "\n\n\n";
  
  std::cout << output_ov1 << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
