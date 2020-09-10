#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto transform_ov1() {
  cest::vector<T> a {};
  cest::vector<T> b {};
  cest::vector<T> c {};
  c.resize(N);

  for (int i = 0; i < N; ++i) {
     a.push_back(i + 1);
     b.push_back(i + 1);
  }

  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    std::transform(std::begin(a), std::end(a), 
                   std::begin(b), std::begin(c), 
                   std::plus<T>());
  } else {
    std::transform(execution::ce_par, std::begin(a), std::end(a), 
                   std::begin(b), std::begin(c), 
                   std::plus<T>());
  }

  return pce::utility::convert_container_to_array<T, N>(c);
}

int main() {
  constexpr auto output_ov1 = transform_ov1<int, 32>();
  auto runtime_ov1 = transform_ov1<int, 32, true>();
  
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
  /*
  for (auto ov : runtime_ov1)
    std::cout << ov << "\n";
        
  std::cout << "\n\n\n";
  
  for (auto ov : output_ov1)
    std::cout << ov << "\n";
    */
  
  return 0;
}
