#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

template <typename T, int N, bool ForceRuntime = false>
constexpr auto replace_copy_if_ov1() {
  cest::vector<int> vec;
  for (int i = 0; i < N; ++i)
    vec.push_back(i);

  cest::vector<int> vec_copy{};
  vec_copy.resize(N);

  auto less_than_15 = [](auto v) { 
    if (v < 15) 
      return true; 
    else 
      return false;
  };

  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    std::replace_copy_if(vec.begin(), vec.end(), vec_copy.begin(), less_than_15, 
                         42);
  } else {
    std::replace_copy_if(execution::ce_par, vec.begin(), vec.end(), 
                         vec_copy.begin(), less_than_15, 42);
  }

  return std::pair<std::array<T, N>, std::array<T, N>>(
      pce::utility::convert_container_to_array<T, N>(vec_copy),
      pce::utility::convert_container_to_array<T, N>(vec));
}

int main() {
  constexpr auto output_ov1 = replace_copy_if_ov1<int, 32>();
  auto runtime_ov1 = replace_copy_if_ov1<int, 32, true>();

  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(std::get<0>(output_ov1), 
                                                    std::get<0>(runtime_ov1))
     && pce::utility::check_runtime_against_compile(std::get<1>(output_ov1), 
                                                    std::get<1>(runtime_ov1)))
    << "\n";

  return 0;
}
