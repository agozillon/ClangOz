#include <iostream>
#include <array>

namespace pce::utility {

template <typename T>
void print_arr(T arr) {
  std::cout << "start \n\n\n";
    
  for (auto a : arr)
    std::cout << "runtime output: " << a << "\n";
  
  std::cout << "\n\n\n end \n\n\n";
  
}

template <typename T, int N>
bool check_runtime_against_compile(std::array<T, N> v,
                                   std::array<T, N> v2) {
  bool ret = true;
  
  for (int i = 0; i < v.size(); ++i)
    if (v[i] != v2[i])
      ret = false;
  
  return ret;
}

template <typename T, typename T2, int N>
bool check_runtime_against_compile(std::pair<T, T2> v,
                                   std::pair<T, T2> v2) {
  bool ret = true;
  
  if (v.first != v2.first && v.second != v2.second)
    ret = false;
  
  return ret;
}

template <typename T, int N = 1>
bool check_runtime_against_compile(T v,
                                   T v2) {
  return (v == v2);
}

}
