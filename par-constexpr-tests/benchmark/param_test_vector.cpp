#include <algorithm>
#include <execution>
#include "cest/vector.hpp"

#ifndef SZ
#define SZ 4096
#endif

// $CLANGOZ/bin/clang++ -I $CEST_INCLUDE -fconstexpr-steps=4294967295 -std=c++2a -stdlib=libc++ -fexperimental-constexpr-parallel param_test_vector.cpp

template <typename T, typename P>
constexpr bool doit(P pol)
{
  T x(SZ);
  std::for_each(pol, x.begin(), x.end(), [](auto &i){ i = 0; });
  bool b = std::all_of(pol, x.begin(), x.end(),
                       [](auto &i){ return i%2 == 0; });
  return b;
}

int main(int argc, char *argv[])
{
  auto pol = __cep::experimental::execution::ce_par;
  //auto pol = std::execution::seq; // error?
  static_assert(doit<cest::vector<int>>(pol));
  return 0;
}
