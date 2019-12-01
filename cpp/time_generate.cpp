#include "Solver.h"
#include <chrono>
#include <iostream>
#include <numeric>
#include <vector>

using namespace std;
using namespace Sudoku;

template <typename Operation> double measure_duration(Operation operate) {
  auto start_time = chrono::steady_clock::now();
  operate();
  auto end_time = chrono::steady_clock::now();
  chrono::duration<double, milli> elapsed = end_time - start_time;
  return elapsed.count();
}

double mean(vector<double> v) {
  return accumulate(v.begin(), v.end(), 0.0) / v.size();
}

int main() {
  vector<double> durations;

  for (int i = 0; i < 100; i++) {
    durations.push_back(measure_duration([&]() { Solver::generate(); }));
  }

  cout << mean(durations) << " ms" << endl;

  return 0;
}
