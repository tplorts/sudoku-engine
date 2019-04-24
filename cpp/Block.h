#if !defined(_SUDOKU_BLOCK_H_)
#define _SUDOKU_BLOCK_H_

#include "Cell.h"
#include "Position.h"
#include "Section.h"
#include "common.h"

namespace Sudoku {

class Block : public Section {
private:
  const Position base;

public:
  Block(const Grid& grid, int block_row_index, int block_column_index)
      : Section(grid), base(block_row_index * B, block_column_index * B) {}

  Block(const Grid& grid, const Block& source)
      : Section(grid, source), base(source.base) {}

  ~Block() {}

  bool includes_row(int row) const {
    return base.row() <= row && row < (base.row() + B);
  }

  bool includes_column(int column) const {
    return base.column() <= column && column < (base.column() + B);
  }

  bool includes(const Position& position) const {
    return includes_row(position.row()) && includes_column(position.column());
  }

  void each_position(PositionFunction operate) const {
    for (int subrow_index = 0; subrow_index < B; subrow_index++) {
      for (int subcolumn_index = 0; subcolumn_index < B; subcolumn_index++) {
        operate(base + Position(subrow_index, subcolumn_index));
      }
    }
  }
};

} // namespace Sudoku

#endif // _SUDOKU_BLOCK_H_
