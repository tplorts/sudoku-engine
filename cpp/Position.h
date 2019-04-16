#if !defined(_POSITION_H_)
#define _POSITION_H_

#include "common.h"
#include <limits>

namespace Sudoku {

const int UNDETERMINED_INDEX = std::numeric_limits<int>::max();

class Position {
private:
  const int row_index;
  const int column_index;

public:
  static Position undetermined() {
    return Position(UNDETERMINED_INDEX, UNDETERMINED_INDEX);
  }

  Position(int r, int c) : row_index(r), column_index(c) {}

  int row() const { return row_index; }
  int column() const { return column_index; }

  int block_row() const { return row_index / B; }
  int block_column() const { return column_index / B; }

  Position operator+(const Position& other) const {
    return Position(row() + other.row(), column() + other.column());
  }

  bool is_row_determined() const { return row_index != UNDETERMINED_INDEX; }
  bool is_column_determined() const {
    return column_index != UNDETERMINED_INDEX;
  }
};

} // namespace Sudoku

#endif // _POSITION_H_
