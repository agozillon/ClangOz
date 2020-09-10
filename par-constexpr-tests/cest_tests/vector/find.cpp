#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto find_ov1() {
  cest::vector<T> vec {};
    
  for (int i = 0; i < N; ++i)
    vec.push_back(i);

  int* found; 
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    found = std::find(vec.begin(), vec.end(), 27);
  } else {
    found = std::find(execution::ce_par, vec.begin(), vec.end(), 27);
  }
  
  return *found;
}

int main() {
  constexpr auto output_ov1 = find_ov1<int, 32>();
  auto runtime_ov1 = find_ov1<int, 32, true>();

  std::cout << output_ov1 << "\n";
  
  std::cout << "\n\n\n";
  
  std::cout << runtime_ov1 << "\n";
      
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
