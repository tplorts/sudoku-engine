#include "Cell.h"
#include "common.h"
#include <iostream>
#include <vector>

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

void Cell::eliminate_candidate(cell_t candidate_value) {
  candidates.reset(candidate_value - 1);
  if (!occupied() && candidate_count() == 0) {
    // cerr << "CellContradiction" << endl;
    throw CellContradiction();
  }
}

cell_t Cell::first_candidate() const {
  cell_t n = 1;
  while (n <= N && !is_candidate(n))
    n++;
  return n;
}

vector<cell_t> Cell::candidate_values() const {
  vector<cell_t> candidates;
  candidates.reserve(candidate_count());

  for (cell_t n = 1; n <= N; n++) {
    if (is_candidate(n)) {
      candidates.push_back(n);
    }
  }

  return candidates;
}
