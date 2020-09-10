#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

constexpr int arr_sz = 32;
using arr_t = int;

static constexpr cest::vector<int> vec1;
static constexpr cest::vector<int> vec2;

template <typename T, int N, bool ForceRuntime = false>
constexpr auto replace_copy_if_ov1(auto& vec) {
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

  return pce::utility::convert_container_to_array<T, N>(vec_copy);
}

int main() {
  for (int i = 0; i < arr_sz; ++i) {
    vec1.push_back(i);
    vec2.push_back(i);
  }

  constexpr auto output_ov1 = replace_copy_if_ov1<arr_t, arr_sz>(vec1);
  auto runtime_ov1 = replace_copy_if_ov1<arr_t, arr_sz, true>(vec2);

  for (auto r : runtime_ov1)
    std::cout << r << "\n";
  
  std::cout << "\n\n\n";
  
  for (auto r : output_ov1)
    std::cout << r << "\n";
  
  std::cout << "\n\n\n";
  
  for (auto r : arr)
    std::cout << r << "\n";
  
  std::cout << "\n\n\n";
  
  for (auto r : arr2)
    std::cout << r << "\n";
    
  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
     && pce::utility::check_runtime_against_compile(arr, arr2))
    << "\n";

  return 0;
}
