#include <algorithm>
#include <execution>
#include <utility>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto replace_copy_ov1() {
  cest::vector<int> vec;

  for (int i = 0; i < N; ++i)
    vec.push_back(i);

  cest::vector<int> vec_copy{};
  vec_copy.resize(N);

  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";

    std::replace_copy(vec.begin(), vec.end(), vec_copy.begin(), 8, 88);
  } else {
    std::replace_copy(execution::ce_par, vec.begin(), vec.end(), 
                      vec_copy.begin(), 8, 88);
  }

  return std::pair<std::array<T, N>, std::array<T, N>>(
      pce::utility::convert_container_to_array<T, N>(vec_copy),
      pce::utility::convert_container_to_array<T, N>(vec));
}

int main() {
  constexpr auto output_ov1 = replace_copy_ov1<int, 32>();
  auto runtime_ov1 = replace_copy_ov1<int, 32, true>();

  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(std::get<0>(output_ov1), 
                                                    std::get<0>(runtime_ov1))
     && pce::utility::check_runtime_against_compile(std::get<1>(output_ov1), 
                                                    std::get<1>(runtime_ov1)))
    << "\n";

  return 0;
}
