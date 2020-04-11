#include <array>
#include <numeric>
#include <iostream>

consteval auto iota_array() {
  std::array<double, 320000> a = {0};
  std::iota(a.begin(), a.end(), 0);
  return a;
}

int main() {
  constexpr auto arr = iota_array();
  
  for (int i = 0; i < 320000; ++i) {
    std::cout << "Arr Val: " << arr[i] << "\n";
  }
  return 0;
}
