#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, int Offset, bool ForceRuntime = false>
constexpr auto none_of_ov1() {
  cest::vector<T> vec{};

  for (int i = 0; i < N; ++i)
    vec.push_back((i + 1) * Offset);
  
    bool t1, t2;
  
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    t1 = std::none_of(vec.begin(), vec.end(), 
                     [](auto i){ return (i % 2 == 0); });
    
    t2 = std::none_of(vec.begin(), vec.end(), 
                     [](auto i){ return (i % 2 == 1); });
  } else {
    // the input and output probably can't alias
    t1 = std::none_of(execution::ce_par, vec.begin(), vec.end(), 
                    [](auto i){ return (i % 2 == 0); });
    
    t2 = std::none_of(execution::ce_par, vec.begin(), vec.end(), 
                     [](auto i){ return (i % 2 == 1); });
  }

  return (t1 == true && t2 == false);
}

int main() {
  constexpr auto output_ov1 = none_of_ov1<int, 32, 2>();
  auto runtime_ov1 = none_of_ov1<int, 32, 2, true>();
  
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
    
  return 0;
}
