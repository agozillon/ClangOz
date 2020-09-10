#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto copy_ov1() {
  cest::vector<T> vec {};
  cest::vector<T> vec_copy {};
  vec_copy.resize(N);

  for (int i = 0; i < N; ++i)
    vec.push_back(i);

  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    std::copy(vec.begin(), vec.end(), vec_copy.begin());
  } else {
    std::copy(execution::ce_par, vec.begin(), vec.end(), vec_copy.begin());
  }
  
  return pce::utility::convert_container_to_array<T, N>(vec_copy);
}

int main() {
  constexpr auto output_ov1 = copy_ov1<int, 32>();
  auto runtime_ov1 = copy_ov1<int, 32, true>();

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
