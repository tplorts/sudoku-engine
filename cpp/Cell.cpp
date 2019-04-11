#include "Cell.h"
#include "common.h"
#include <iostream>

using namespace std;
using namespace Sudoku;

void Cell::place(cell_t new_value) {
  if (occupied()) {
    cerr << "Tried to place " << new_value << " in occupied cell!" << endl;
    return;
  }

  value = new_value;

  // There are now no candidates
  candidates.reset();
}

cell_t Cell::first_candidate() const {
  cell_t n = 1;
  while (n <= N && !is_candidate(n))
    n++;
  return n;
}
