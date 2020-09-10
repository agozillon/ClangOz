#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

auto is_even = [](int i){ return i % 2 == 0; };

template <typename T, int N, bool ForceRuntime = false,  bool Partition = false>
constexpr auto is_partitioned_ov1() {
  cest::vector<int> vec {};

  for (int i = 0; i < N; ++i)
    vec.push_back(i);

  if constexpr (Partition) {
    std::partition(vec.begin(), vec.end(), is_even);
  }
  
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    return std::is_partitioned(vec.begin(), vec.end(), is_even);
  } else {
    return std::is_partitioned(execution::ce_par, vec.begin(), vec.end(), 
                               is_even);
  }
}

int main() {
  constexpr auto output_ov1 = is_partitioned_ov1<int, 32>();
  auto runtime_ov1 = is_partitioned_ov1<int, 32, true>();

//  std::cout << "output_ov1: " << output_ov1 << "\n";
//  std::cout << "runtime_ov1: " << runtime_ov1 << "\n";

  constexpr auto output_ov1_nonpart = is_partitioned_ov1<int, 32, false, 
                                                         true>();
  auto runtime_ov1_nonpart = is_partitioned_ov1<int, 32, true, true>();
  
//  std::cout << "output_ov1_nonpart: " << output_ov1_nonpart << "\n";
//  std::cout << "runtime_ov1_nonpart: " << runtime_ov1_nonpart << "\n";

  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(output_ov1_nonpart,
                                                   runtime_ov1_nonpart)
        && pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1))
    << "\n";

  return 0;
}
