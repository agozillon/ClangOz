#include <array>
#include <algorithm>
#include <execution>

#ifndef SZ
#define SZ 4096
#endif

// $CLANGOZ/bin/clang++ -DCONSTEXPR_PAR -fconstexpr-steps=4294967295 -std=c++2a   -stdlib=libc++ -fexperimental-constexpr-parallel param_test.cpp

template <typename T, typename P>
constexpr bool doit(P pol)
{
  T x;
  std::for_each(pol, x.begin(), x.end(), [](auto &i){ i = 0; });
  bool b = std::all_of(pol, x.begin(), x.end(),
                       [](auto &i){ return i%2 == 0; });
  return b;
}

int main(int argc, char *argv[])
{
  auto pol = __cep::experimental::execution::ce_par;
  //auto pol = std::execution::seq; // error?
  static_assert(doit<std::array<int,SZ>>(pol));
  return 0;
}
