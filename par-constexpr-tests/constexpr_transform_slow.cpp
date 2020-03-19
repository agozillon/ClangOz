#include <array>
#include <algorithm>
#include <iostream>
#include <numeric>
#include <iterator>

// clang++ -fconstexpr-steps=2147483647 -std=c++2a -stdlib=libc++ \
//    constexpr_transform_slow.cpp
//
// 
// clang++ -ftime-report -fconstexpr-steps=2147483647 -std=c++2a \
//  -stdlib=libc++ constexpr_transform_slow.cpp


// TEST IF WEIRD SEG FAULT HAPPENS WITH UNMODED CLANG LLVM
// TODO:
// a) Remember this only works for double, because the size of the types
//    when offsetting the pointer is currently not taken into consideration 
// b) Check why this segfaults with 1200000 (Breaks at 64000) elements with and 
// without the parallel implementation, more importantly check if it works fine 
// with a version of the compiler ive not touched.
constexpr auto test_constexpr_transform() {
    std::array<double, 320000> a = {0};
    std::array<double, 320000> b = {0};
    std::array<double, 320000> c = {0};
    std::array<double, 320000> expected = {0};

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
                             [](auto& lhs, auto& rhs) { return lhs + rhs; }); // basically std::plus

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


consteval auto golden_array() {
  std::array<double, 320000> a = {0};
  std::iota(a.begin(), a.end(), 0);
  std::for_each(a.begin(), a.end(), [](auto &i){ i *= 2; });
  return a;
}

int main() {
  constexpr auto transformed = test_constexpr_transform(); 
  constexpr auto golden = golden_array();
  
  static_assert(transformed == golden);
  static_assert(test_constexpr_transform() == golden_array());
  
  std::cout << "transformed.size(): " << transformed.size() << "\n";
  bool correct = true;
  for (int i = 0; i < transformed.size(); ++i) {
    if (transformed[i] != i * 2 || transformed[i] != golden[i])
      correct = false;
  }
  
  if (!correct)
    std::cout << "incorrect values at runtime \n";
  else 
    std::cout << "correct values at runtime \n";
  
  return 0;
}
