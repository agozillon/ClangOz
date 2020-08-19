#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <execution>

using namespace __cep::experimental;

#include "../helpers/test_helpers.hpp"
#include "../libcxx_support/test_iterators.h"

template <bool ForceRuntime = false, bool Ordered = false>
constexpr auto lexicographical_compare_ov1() {
  std::array<char, 4> main_arr {'a', 'b', 'c', 'd'};
  std::array<char, 8> second_arr;

  if constexpr (Ordered) {
    second_arr = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h'};
  } else {
    second_arr = {'a', 'b', 'e', 'c', 'd', 'f', 'h', 'g'};
  }
  
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
    return std::lexicographical_compare(main_arr.begin(), main_arr.end(), 
                                        second_arr.begin(), second_arr.end());
  } else {
    return std::lexicographical_compare(execution::ce_par, main_arr.begin(), 
                                        main_arr.end(), second_arr.begin(), 
                                        second_arr.end());
  }
}

// Borrowing some libcxx tests, in the long distant future hooking the parallel
// algorithms up to the libcxx tests would be a cool idea.
bool test_constexpr() {
    int ia[] = {1, 2, 3};
    int ib[] = {1, 3, 5, 2, 4, 6};

    return  std::lexicographical_compare(execution::ce_par, std::begin(ia), 
                                         std::end(ia), std::begin(ib), 
                                         std::end(ib))
        && !std::lexicographical_compare(execution::ce_par, std::begin(ib), 
                                         std::end(ib), std::begin(ia), 
                                         std::end(ia));
}

template <class Iter1, class Iter2>
constexpr void test_iters() {
    constexpr int ia[] = {1, 2, 3, 4};
    const unsigned sa = sizeof(ia)/sizeof(ia[0]);
    constexpr int ib[] = {1, 2, 3};
    typedef std::greater<int> C;
    C c;
    static_assert(!std::lexicographical_compare(execution::ce_par, Iter1(ia),   Iter1(ia+sa), Iter2(ib),   Iter2(ib+2),  c));
    static_assert( std::lexicographical_compare(execution::ce_par, Iter1(ib),   Iter1(ib+2),  Iter2(ia),   Iter2(ia+sa), c));
    static_assert(!std::lexicographical_compare(execution::ce_par, Iter1(ia),   Iter1(ia+sa), Iter2(ib),   Iter2(ib+3),  c));
    static_assert( std::lexicographical_compare(execution::ce_par, Iter1(ib),   Iter1(ib+3),  Iter2(ia),   Iter2(ia+sa), c));
    static_assert(!std::lexicographical_compare(execution::ce_par, Iter1(ia),   Iter1(ia+sa), Iter2(ib+1), Iter2(ib+3),  c));
    static_assert( std::lexicographical_compare(execution::ce_par, Iter1(ib+1), Iter1(ib+3),  Iter2(ia),   Iter2(ia+sa), c));
}

void libcxx_tests() {
    test_iters<input_iterator<const int*>, input_iterator<const int*> >();
    test_iters<input_iterator<const int*>, forward_iterator<const int*> >();
    test_iters<input_iterator<const int*>, bidirectional_iterator<const int*> >();
    test_iters<input_iterator<const int*>, random_access_iterator<const int*> >();
    test_iters<input_iterator<const int*>, const int*>();
}

int main() {
  libcxx_tests();

  constexpr auto output_ov1 = lexicographical_compare_ov1<false>();
  auto runtime_ov1 = lexicographical_compare_ov1<true>();

  constexpr auto output_ov1_ordered 
      = lexicographical_compare_ov1<false, true>();
  auto runtime_ov1_ordered = lexicographical_compare_ov1<true, true>();
  
  std::cout << "output_ov1_ordered: " << output_ov1_ordered << "\n";
  std::cout << "runtime_ov1_ordered: " << runtime_ov1_ordered << "\n";
  
  std::cout << "Runtime == Compile Time: " 
    << (pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1) &&
       pce::utility::check_runtime_against_compile(output_ov1_ordered, 
                                                   runtime_ov1_ordered) && 
                                                   test_constexpr()) << "\n";

  return 0;
}
