#include "Solver.h"
#include <iostream>

using namespace std;
using namespace Sudoku;

int main() {
  Solver solver("../puzzles/20190220a.sudoku");

  cout << "Before:" << endl << solver << endl;

  solver.solve();

  cout << "After:" << endl << solver << endl;

  return 0;
}
