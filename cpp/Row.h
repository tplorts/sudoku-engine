#if !defined(_SUDOKU_ROW_H_)
#define _SUDOKU_ROW_H_

#include "Cell.h"
#include "Section.h"
#include "common.h"

namespace Sudoku {

class RowIterator : public SectionIterator {
private:
  const int row_index;

public:
  RowIterator(const Grid& grid, int row_index)
      : SectionIterator(grid), row_index(row_index) {}

  Cell& next() { return (Cell&)grid(row_index, next_index++); }
};

class Row : public Section {
private:
  const int row_index;

public:
  Row(const Grid& grid, int row_index) : Section(grid), row_index(row_index) {}

  ~Row() {}

  SectionIterator* get_iterator() { return new RowIterator(grid, row_index); }
};

} // namespace Sudoku

#endif // _SUDOKU_ROW_H_
