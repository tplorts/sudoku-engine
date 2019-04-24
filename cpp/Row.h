#if !defined(_SUDOKU_ROW_H_)
#define _SUDOKU_ROW_H_

#include "Cell.h"
#include "Position.h"
#include "Section.h"
#include "common.h"

namespace Sudoku {

class Row : public Section {
private:
  const int row_index;

public:
  Row(const Grid& grid, int row_index) : Section(grid), row_index(row_index) {}
  Row(const Grid& grid, const Row& source)
      : Section(grid, source), row_index(source.row_index) {}

  ~Row() {}

  void each_position(PositionFunction operate) const {
    for (int column_index = 0; column_index < N; column_index++) {
      operate(Position(row_index, column_index));
    }
  }
};

} // namespace Sudoku

#endif // _SUDOKU_ROW_H_
