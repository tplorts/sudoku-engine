#if !defined(_SUDOKU_GRID_H_)
#define _SUDOKU_GRID_H_

#include "Cell.h"
#include "Position.h"
#include "common.h"
#include <iostream>

namespace Sudoku {

class Grid {
private:
  Cell table[N][N];

public:
  Grid() {}
  ~Grid() {}

  Cell& operator()(int row_index, int column_index) {
    return table[row_index][column_index];
  }

  const Cell& operator()(int row_index, int column_index) const {
    return table[row_index][column_index];
  }

  Cell& operator()(const Position& position) {
    return (*this)(position.row(), position.column());
  }

  const Cell& operator()(const Position& position) const {
    return (*this)(position.row(), position.column());
  }
};

} // namespace Sudoku

std::ostream& operator<<(std::ostream& outs, const Sudoku::Grid& grid);

#endif // _SUDOKU_GRID_H_
