#include "Solver.h"
#include "Position.h"
#include <string>

using namespace std;
using namespace Sudoku;

void Solver::solve() {
  int i = 0;
  while (!complete()) {
    int initial_empty_count = empty_cell_count();

    fill_determined_cells();

    int placements_made = initial_empty_count - empty_cell_count();
    if (placements_made == 0) {
      // stuck
      break;
    }
  }
}

void Solver::fill_determined_cells() {
  for (int row_index = 0; row_index < N; row_index++) {
    for (int column_index = 0; column_index < N; column_index++) {
      Position position(row_index, column_index);
      Cell& cell = sudoku.get_cell(position);

      if (cell.determined()) {
        sudoku.place(cell.first_candidate(), position);
      }
    }
  }
}