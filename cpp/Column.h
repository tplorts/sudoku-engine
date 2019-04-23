#if !defined(_SUDOKU_COLUMN_H_)
#define _SUDOKU_COLUMN_H_

#include "Cell.h"
#include "Position.h"
#include "Section.h"
#include "common.h"

namespace Sudoku {

class Column : public Section {
private:
  const int column_index;

public:
  Column(const Grid& grid, int column_index)
      : Section(grid), column_index(column_index) {}

  ~Column() {}

  void each_position(PositionFunction operate) const {
    for (int row_index = 0; row_index < N; row_index++) {
      operate(Position(row_index, column_index));
    }
  }
};

} // namespace Sudoku

#endif // _SUDOKU_COLUMN_H_
