#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

using namespace __cep::experimental;

#include "../../helpers/test_helpers.hpp"

/* Make a generic way to make/reuse tests, we only really need a unique way to
   populate the containers after feeding it data */

/* Maybe we could make a parallel constexpr alloc that will reserve a block of 
   data to keep things contigious...? */

/*
  Test some non-linear push_back's to see if this affects the contigiousness of
  data
*/
/* consteval seems to be quite fragile, I've made the compiler ICE several times
   using it in place of constexpr, swapping constexpr to consteval in the below
   function ICE's the clang compiler I have (even without running the par
   constexpr stuff)!
*/
template <typename T, int N, bool ForceRuntime = false>
constexpr auto for_each_vec() {
  cest::vector<int> vec{};

  for (int i = 0; i < N; ++i)
    vec.push_back(i + 32);

  if constexpr (ForceRuntime) {
    std::cout << "is constant evaluated: " 
              << std::is_constant_evaluated() << "\n";
              
    std::for_each(vec.begin(), vec.end(), [](auto &i){ i *= 2; });
  } else {
    std::for_each(execution::ce_par, vec.begin(), vec.end(), 
                  [](auto &i){ i *= 2; });
  }

  return pce::utility::convert_container_to_array<T, N>(vec);
}

int main() {
  constexpr auto output_ov1 = for_each_vec<int, 32>();
  auto runtime_ov1 = for_each_vec<int, 32, true>();

  for (auto r : output_ov1)
    std::cout << r << "\n";

//  std::cout << "\n\n\n";

//  for (auto r : runtime_ov1)
//    std::cout << r << "\n";
    
  std::cout << "Runtime == Compile Time: " 
    << pce::utility::check_runtime_against_compile(output_ov1, runtime_ov1)
    << "\n";

  return 0;
}
