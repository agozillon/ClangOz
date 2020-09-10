#include <algorithm>
#include <execution>
#include <utility>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"


constexpr int arr_sz = 32;
using arr_t = int;

template <typename T, int N, bool ForceRuntime = false>
constexpr auto move_ov1() {
  cest::vector<T> vec_move {};
  cest::vector<T> vec {};
  vec_move.resize(N);

  for (int i = 0; i < N; ++i)
    vec.push_back(i);
    
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    std::move(vec.begin(), vec.end(), vec_move.begin());
  } else {
    std::move(execution::ce_par, vec.begin(), vec.end(), vec_move.begin());
  }
  
  return std::make_pair(pce::utility::convert_container_to_array<T, N>(vec_move),
                        pce::utility::convert_container_to_array<T, N>(vec));
}

int main() {
  constexpr auto output_ov1 = move_ov1<arr_t, arr_sz>();
  auto runtime_ov1 = move_ov1<arr_t, arr_sz, true>();

  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(std::get<0>(output_ov1), 
                                                    std::get<1>(runtime_ov1))
     && pce::utility::check_runtime_against_compile(std::get<0>(output_ov1), 
                                                    std::get<1>(runtime_ov1)))
    << "\n";

  return 0;
}
