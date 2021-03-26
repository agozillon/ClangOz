#ifndef _BLACKSCHOLES_IN_4_
#define _BLACKSCHOLES_IN_4_

constexpr int numOfData = 4;

// we care about everything except divq/divs/dgrefval they don't seem to be used
// s / strike / r / divq / v  / t / optiontype / divs / dgrefval 

constexpr const char* inputData {
 R"(42.00 40.00 0.1000 0.00 0.20 0.50 C 0.00 4.759423036851750055
42.00 40.00 0.1000 0.00 0.20 0.50 P 0.00 0.808600016880314021
100.00 100.00 0.0500 0.00 0.15 1.00 P 0.00 3.714602051381290071
100.00 100.00 0.0500 0.00 0.15 1.00 C 0.00 8.591659601309890704 )"
};

#endif 
