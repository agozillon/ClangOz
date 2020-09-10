#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

constexpr int arr_sz = 32;
using arr_t = int;

template <typename T, int N, bool ForceRuntime = false>
constexpr auto swap_ranges_ov1() {
  cest::vector<int> vec_swap {};
  cest::vector<int> vec {};
  
  for (int i = 0; i < N; ++i)
    vec.push_back(i);
    
  for (int i = 0; i < N; ++i)
    vec_swap.push_back(N + i);
    
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    std::swap_ranges(vec.begin(), vec.end(), vec_swap.begin());
  } else {
    std::swap_ranges(execution::ce_par, vec.begin(), vec.end(), 
                     vec_swap.begin());
  }
  
  return std::pair< std::array<T, N>,  std::array<T, N>>(
    pce::utility::convert_container_to_array<T, N>(vec), 
    pce::utility::convert_container_to_array<T, N>(vec_swap));
}

int main() {
  constexpr auto output_ov1 = swap_ranges_ov1<arr_t, arr_sz>();
  auto runtime_ov1 = swap_ranges_ov1<arr_t, arr_sz, true>();

//  for (auto r : std::get<0>(runtime_ov1))
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : std::get<0>(output_ov1))
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : std::get<1>(runtime_ov1))
//    std::cout << r << "\n";
//  
//  std::cout << "\n\n\n";
//  
//  for (auto r : std::get<1>(output_ov1))
//    std::cout << r << "\n";
    
  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(std::get<0>(runtime_ov1), 
                                                    std::get<0>(output_ov1))
     && pce::utility::check_runtime_against_compile(std::get<1>(runtime_ov1), 
                                                    std::get<1>(output_ov1)))
    << "\n";

  return 0;
}
