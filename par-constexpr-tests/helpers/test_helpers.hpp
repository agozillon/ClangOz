#include <iostream>
#include <array>

namespace pce::utility {

// Taken from: https://tristanbrindle.com/posts/a-more-useful-compile-time-quicksort 
// libcxx's sort currently isn't constexpr and until I get around to tinkering 
// with it I thought borrowing this quicksort implementation for the time being
// is ideal!
namespace cstd {

template <typename RAIt>
constexpr RAIt next(RAIt it,
                    typename std::iterator_traits<RAIt>::difference_type n = 1)
{
    return it + n;
}

template <typename RAIt>
constexpr auto distance(RAIt first, RAIt last)
{
    return last - first;
}

template<class ForwardIt1, class ForwardIt2>
constexpr void iter_swap(ForwardIt1 a, ForwardIt2 b)
{
    auto temp = std::move(*a);
    *a = std::move(*b);
    *b = std::move(temp);
}

template<class InputIt, class UnaryPredicate>
constexpr InputIt find_if_not(InputIt first, InputIt last, UnaryPredicate q)
{
    for (; first != last; ++first) {
        if (!q(*first)) {
            return first;
        }
    }
    return last;
}

template<class ForwardIt, class UnaryPredicate>
constexpr ForwardIt partition(ForwardIt first, ForwardIt last, UnaryPredicate p)
{
    first = cstd::find_if_not(first, last, p);
    if (first == last) return first;

    for(ForwardIt i = cstd::next(first); i != last; ++i){
        if(p(*i)){
            cstd::iter_swap(i, first);
            ++first;
        }
    }
    return first;
}

}

template<class RAIt, class Compare = std::less<>>
constexpr void quick_sort(RAIt first, RAIt last, Compare cmp = Compare{})
{
    auto const N = cstd::distance(first, last);
    if (N <= 1) return;
    auto const pivot = *cstd::next(first, N / 2);
    auto const middle1 = cstd::partition(first, last, [=](auto const& elem){
        return cmp(elem, pivot);
    });
    auto const middle2 = cstd::partition(middle1, last, [=](auto const& elem){
        return !cmp(pivot, elem);
    });
    quick_sort(first, middle1, cmp); // assert(std::is_sorted(first, middle1, cmp));
    quick_sort(middle2, last, cmp);  // assert(std::is_sorted(middle2, last, cmp));
}

// The random number generator is borrowed from C++ Weekly Ep 44:
// https://www.youtube.com/watch?v=rpn_5Mrrxf8 as the std random number 
// generators don't appear to be constexpr yet
constexpr auto seed()
{
  std::uint64_t shifted = 0;

  for( const auto c : __TIME__ )
  {
    shifted <<= 8;
    shifted |= c;
  }

  return shifted;
}

struct PCG
{
  struct pcg32_random_t { std::uint64_t state=seed();  std::uint64_t inc=seed(); };
  pcg32_random_t rng;
  typedef std::uint32_t result_type;

  constexpr result_type operator()()
  {
    return pcg32_random_r();
  }

  static result_type constexpr min()
  {
    return std::numeric_limits<result_type>::min();
  }

  static result_type constexpr max()
  {
    return std::numeric_limits<result_type>::max();
  }

  private:
  constexpr std::uint32_t pcg32_random_r()
  {
    std::uint64_t oldstate = rng.state;
    // Advance internal state
    rng.state = oldstate * 6364136223846793005ULL + (rng.inc|1);
    // Calculate output function (XSH RR), uses old state for max ILP
    std::uint32_t xorshifted = ((oldstate >> 18u) ^ oldstate) >> 27u;
    std::uint32_t rot = oldstate >> 59u;
    return (xorshifted >> rot) | (xorshifted << ((-rot) & 31));
  }

};

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

template <typename T, int count> 
constexpr auto generate_array_within_range(T min, T max) {
  PCG pcg;
  std::array<T, count> v;

  for (int i = 0; i < count; ++i)
    v[i] = (T)(((float)pcg() / (float)pcg.max()) * (max - min + 1)) + min;
  
  return v;
}

template <typename T, int N>
constexpr auto remove_dups_from_sorted(std::array<T, N> v) {
  std::array<T, N> new_arr{};
  T last_unique = new_arr[0] = v[0];
  
  int counter = 0;
  for (int i = 1; i < v.size(); ++i) {
    if (last_unique != v[i]) {
      new_arr[counter] = v[i];
      counter++;
      last_unique = v[i];
    }
  }
  
  return new_arr;
}

// helper to convert container with iterator to a std::array at compile time, 
// generally for use with dynamic containers
template <typename T, int N>
constexpr auto convert_container_to_array(auto container) {
  std::array<T, N> new_arr{};
  int i = 0;
  for (auto it = container.begin(); it != container.end(); ++it) {
    new_arr[i] = *it;
    ++i;
  }
  
  return new_arr;
}

}
