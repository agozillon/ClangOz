#include <array>
#include <algorithm>
#include <iostream>
#include <numeric>
#include <iterator>

#ifdef CONSTEXPR_PAR
#include <execution>
using namespace __cep::experimental;
#endif

// it's likely better just to use linux's time to get an overall read of the 
// speed rather than -ftime-report, which is more focused on breaking down the
// time spent in LLVM
//
// No parallelism:
// 
// clang++ -fconstexpr-steps=4294967295 -std=c++2a -stdlib=libc++ \
//    constexpr_transform_slow.cpp
//
// clang++ -ftime-report -fconstexpr-steps=4294967295 -std=c++2a \
//  -stdlib=libc++ constexpr_transform_slow.cpp
//
// With Parallelism: 
//
// $CLANGOZ/bin/clang++ -DCONSTEXPR_PAR -fconstexpr-steps=4294967295 -std=c++2a 
//  -stdlib=libc++ -fexperimental-constexpr-parallel 
//  constexpr_transform_slow.cpp
//
// $CLANGOZ/bin/clang++ -DCONSTEXPR_PAR -ftime-report
//  -fconstexpr-steps=4294967295 -std=c++2a -stdlib=libc++
//  -fexperimental-constexpr-parallel constexpr_transform_slow.cpp
//
// I moved away from using -ftime-reprot to just using linux's time function, 
// less verbose output.

template <typename T>
constexpr auto test_constexpr_transform() {
    std::array<T, 320000> a = {0};
    std::array<T, 320000> b = {0};
    std::array<T, 320000> c = {0};
    std::array<T, 320000> expected = {0};

#ifdef CONSTEXPR_PAR
    std::iota(execution::ce_par, a.begin(), a.end(), 0);
    std::iota(execution::ce_par, b.begin(), b.end(), 0);
    std::iota(execution::ce_par, expected.begin(), expected.end(), 0);
    
    std::for_each(execution::ce_par, expected.begin(), expected.end(), 
                  [](auto &i){ i *= 2; });
    
    // I think the broken return iterator might be part of creating the 
    // temporaries and only using those, it'll probably return the original 
    // non-modified iterator, so it won't be at the correct position (end of 
    // the modified array)
    auto it = std::transform(execution::ce_par, std::begin(a), std::end(a), 
                             std::begin(b), std::begin(c), 
                             [](auto& lhs, auto& rhs) { return lhs + rhs; });
#else
    std::iota(a.begin(), a.end(), 0);
    std::iota(b.begin(), b.end(), 0);
    std::iota(expected.begin(), expected.end(), 0);
    
    std::for_each(expected.begin(), expected.end(), [](auto &i){ i *= 2; });
    
    // I think the broken return iterator might be part of creating the 
    // temporaries and only using those, it'll probably return the original 
    // non-modified iterator, so it won't be at the correct position (end of 
    // the modified array)
    auto it = std::transform(std::begin(a), std::end(a), 
                             std::begin(b), std::begin(c), 
                             [](auto& lhs, auto& rhs) { return lhs + rhs; });
#endif
   // you can't actually static_assert and test for equality inside here, for 
   // some reason the std::array's not being declared with constexpr cause this
   // not to be a constant expression inside the scope of this function.
   //
   // Although outside of the scope of the function once the array has been 
   // returned, it's fine to static_assert for equality. Is this a Clang or 
   // libcxx bug or a defect in the standard? Or just me misusing it...
   // 
   // It's also worth noting adding constexpr to the std::array's makes them 
   // const and unuseable with for_each and transform inside the scope of this
   // constexpr call..
//   static_assert(c == expected);
  
   return c; 
}

template <typename T>
consteval auto golden_array() {
  std::array<T, 320000> a = {0};
#ifdef CONSTEXPR_PAR
  std::iota(execution::ce_par, a.begin(), a.end(), 0);
  std::for_each(execution::ce_par, a.begin(), a.end(), [](auto &i){ i *= 2; });
#else
  std::iota(a.begin(), a.end(), 0);
  std::for_each(a.begin(), a.end(), [](auto &i){ i *= 2; });
#endif
  return a;
}

int main() {
  constexpr auto transformed_double = test_constexpr_transform<double>(); 
  constexpr auto golden_double = golden_array<double>();
  constexpr auto transformed_float = test_constexpr_transform<float>(); 
  constexpr auto golden_float = golden_array<float>();
  
  static_assert(transformed_double == golden_double);
  static_assert(transformed_float == golden_float);
  static_assert(test_constexpr_transform<double>() == golden_array<double>());
  static_assert(test_constexpr_transform<float>() == golden_array<float>());
  static_assert(test_constexpr_transform<int>() == golden_array<int>());
  
  std::cout << "transformed_double.size(): " << transformed_double.size() << "\n";
  bool correct = true;
  for (int i = 0; i < transformed_double.size(); ++i) {
    if (transformed_double[i] != i * 2 || 
        transformed_double[i] != golden_double[i])
      correct = false;
  }
  
  std::cout << "transformed_float.size(): " << transformed_float.size() << "\n";
  for (int i = 0; i < transformed_float.size(); ++i) {
    if (transformed_float[i] != i * 2 || 
        transformed_float[i] != golden_float[i])
      correct = false;
  }
  
//  for (int i = 0; i < transformed_float.size(); ++i) {
//    std::cout << "transformed_float: " << transformed_float[i] << "\n";
//  }
//  
//  for (int i = 0; i < transformed_double.size(); ++i) {
//    std::cout << "transformed_double: " << transformed_double[i] << "\n";
//  }
  
  if (!correct)
    std::cout << "incorrect values at runtime \n";
  else 
    std::cout << "correct values at runtime \n";
  
  return 0;
}
