#include "Grid.h"
#include "common.h"
#include <iostream>
#include <string>

using namespace std;
using namespace Sudoku;

Grid::Grid(const Grid& source) {
  for (int row_index = 0; row_index < N; row_index++) {
    for (int column_index = 0; column_index < N; column_index++) {
      table[row_index][column_index] =
          Cell(source.table[row_index][column_index]);
    }
  }
}

ostream& operator<<(ostream& outs, const Grid& grid) {
  const string row_divider_line((N * 4) + 1, '-');

  outs << row_divider_line << endl;

  for (int row_index = 0; row_index < N; row_index++) {
    for (int column_index = 0; column_index < N; column_index++) {
      outs << "| " << grid(row_index, column_index) << ' ';
    }

    outs << '|' << endl << row_divider_line << endl;
  }

  return outs;
}
