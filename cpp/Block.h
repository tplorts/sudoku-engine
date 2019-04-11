#if !defined(_SUDOKU_BLOCK_H_)
#define _SUDOKU_BLOCK_H_

#include "Cell.h"
#include "Section.h"
#include "common.h"

namespace Sudoku {

class BlockIterator : public SectionIterator {
private:
  const int row_offset;
  const int column_offset;

public:
  BlockIterator(const Grid &grid, int row_offset, int column_offset)
      : SectionIterator(grid), row_offset(row_offset),
        column_offset(column_offset) {}

  Cell &next() {
    const int subrow_index = next_index / B;
    const int subcolumn_index = next_index % B;
    next_index++;
    return (Cell &)grid(row_offset + subrow_index,
                        column_offset + subcolumn_index);
  }
};

class Block : public Section {
private:
  const int row_offset;
  const int column_offset;

public:
  Block(const Grid &grid, int block_row_index, int block_column_index)
      : Section(grid), row_offset(block_row_index * B),
        column_offset(block_column_index * B) {}

  ~Block() {}

  SectionIterator *get_iterator() {
    return new BlockIterator(grid, row_offset, column_offset);
  }
};

} // namespace Sudoku

#endif // _SUDOKU_BLOCK_H_
