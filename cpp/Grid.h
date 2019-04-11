#if !defined(_SUDOKU_GRID_H_)
#define _SUDOKU_GRID_H_

#include "Cell.h"
#include "common.h"
#include <iostream>

namespace Sudoku {

class Grid {
private:
  Cell table[N][N];

public:
  Grid() {}
  ~Grid() {}

  Cell &operator()(int row_index, int column_index);
  const Cell &operator()(int row_index, int column_index) const;
};

} // namespace Sudoku

std::ostream &operator<<(std::ostream &outs, const Sudoku::Grid &grid);

#endif // _SUDOKU_GRID_H_
