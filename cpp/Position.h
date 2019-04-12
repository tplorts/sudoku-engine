#if !defined(_POSITION_H_)
#define _POSITION_H_

#include "common.h"

namespace Sudoku {

class Position {
private:
  const int row_index;
  const int column_index;

public:
  Position(int r, int c) : row_index(r), column_index(c) {}

  int row() const { return row_index; }
  int column() const { return column_index; }

  int block_row() const { return row_index / B; }
  int block_column() const { return column_index / B; }

  Position operator+(const Position& other) const {
    return Position(row() + other.row(), column() + other.column());
  }
};

} // namespace Sudoku

#endif // _POSITION_H_
