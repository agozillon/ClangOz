#include <array>
#include <algorithm>
#include <iostream>
#include <type_traits>
#include <iterator>

#include "../helpers/test_helpers.hpp"
/*
  This is as simple as I can get the set_intersection algorithm with it still 
  passing the libcxx tests... but it's still not that ideal as ++__first1 is not 
  really guaranteed to increment
  
  OK, I SHOULD LOOK INTO USING PRAGMAS/ATTRs/OR SYCL STYLE FUNTION HACK OR 
  SOMETHING TO CONVEY INFORMATION, CODE ANALYSIS IS NON-TRIVIAL AND HAS MANY 
  EDGE CASES e.g: 
    How do I tell ++result apart from ++__first1 or ++__first2 when I am 
    looking at the below chunk of code:
   
    for (; __first1 != __last1;) {
      if (__first2 == __last2)
        break;
        
      if (__comp(*__first1, *__first2)) {
        ++__first1;
      } else {
          if (!__comp(*__first2, *__first1))
          {
              *__result = *__first1;
              ++__result;
              ++__first1;
          }
          ++__first2;
      }
    }
  
   The iterators containing the actual iteration space need to be treated 
   differently from the result: 
     1) The compiler needs to move at least __first1 to a different start 
        location per thread
     2) It needs to realize that result likely has to be made private across 
        the threads and then merged into a single result
     3) It needs to realize that __first2 should neither be set to a new start
        location per thread (as we only care about the outer loop when 
        parallelizing), should be privatized but should not be merged into a 
        single final result
        
   Asides from the complexity, the more complex the analyiss the larger the 
   "startup cost" penalty for making something multithreaded.
   
   Coming up with some kind of syntax or semantics for passing information to 
   the compiler is possibly going to be a nightmare in itself though.. at the 
   very baseline a simple "can it work" test interface could be done with 
   noop/id wrapper functions..although likely to come at a non-trivial 
   compile time cost. A proper interface may be builtins or pragmas/attributes
   that can convey the information without causing the constexpr code to have an
   extra non-relevant layer to invoke
   
   Saying all that it sort of works with the above function at the moment, minus 
   the difficulty of working out how to 1)ohandle this particular flavor 
   of reduction and 2) notify the compiler that it needs to reduce that variable
   and in what way, it's notable that count_if already does a reduction
    
    the redlist is 0 interestingly, so it is possible we could work out the 
    issue of not knowing what to reduce and how to still, perhaps its because 
    its an ASSIGNMENT and not an postinc etc. 
    
    
*/

template <typename T, int N, bool ForceRuntime = false>
constexpr auto set_intersection_ov1() {
  // this is just here to make sure the runtime iteration is actually executing
  // at runtime
  if constexpr (ForceRuntime) 
    std::cout << "is constant evaluated: " << std::is_constant_evaluated() << "\n";


  std::array<T, N> out {}; // would be better as a vector, but no constexpr 
                          // vector yet in the std library
  std::array<T, N> arr {};
  std::array<T, 4> arr2 {1, 12, 32, 48}; 
    
  for (int i = 0; i < arr.size(); ++i)
    arr[i] = i;
    
//  auto first1 = arr.begin(); 
//  auto first2 = arr2.begin(); 
//  
//  int count = 0;
//  for ( auto f1 = first1; f1 != arr.end(); ++f1)
//    for ( auto f2 = first2; f2 != arr2.end(); ++f2)
//      count++;
//  
//  std::cout << count << "\n";
  // TODO: check if this works with uneven iterators, I think it won't.
  std::set_intersection_looped(arr.begin(), arr.end(), 
                               arr2.begin(), arr2.end(),
                               out.begin());
  
   return out; 
}

int main() {
  constexpr auto output_ov1 = set_intersection_ov1<int, 32>();
  auto runtime_ov1 = set_intersection_ov1<int, 32, true>();
  
  for (int i = 0; i < 32; ++i) {
    std::cout << output_ov1[i] << " ";
  }
  
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";
  
  return 0;
}
