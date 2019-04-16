#if !defined(_SUDOKU_BLOCK_H_)
#define _SUDOKU_BLOCK_H_

#include "Cell.h"
#include "Position.h"
#include "Section.h"
#include "common.h"

namespace Sudoku {

class BlockIterator : public SectionIterator {
private:
  const Position& base;

  Position next_subposition() {
    const int index = next_index++;
    return Position(index / B, index % B);
  }

public:
  BlockIterator(const Grid& grid, const Position& base)
      : SectionIterator(grid), base(base) {}

  Position next_position() { return base + next_subposition(); }
};

class Block : public Section {
private:
  const Position base;

public:
  Block(const Grid& grid, int block_row_index, int block_column_index)
      : Section(grid), base(block_row_index * B, block_column_index * B) {}

  ~Block() {}

  SectionIterator* get_iterator() const {
    return new BlockIterator(grid, base);
  }

  bool includes_row(int row) const {
    return base.row() <= row && row < (base.row() + B);
  }

  bool includes_column(int column) const {
    return base.column() <= column && column < (base.column() + B);
  }

  bool includes(const Position& position) const {
    return includes_row(position.row()) && includes_column(position.column());
  }
};

} // namespace Sudoku

#endif // _SUDOKU_BLOCK_H_
