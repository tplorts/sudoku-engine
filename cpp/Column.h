#if !defined(_SUDOKU_COLUMN_H_)
#define _SUDOKU_COLUMN_H_

#include "Cell.h"
#include "Section.h"
#include "common.h"

namespace Sudoku {

class ColumnIterator : public SectionIterator {
private:
  const int column_index;

public:
  ColumnIterator(const Grid& grid, int column_index)
      : SectionIterator(grid), column_index(column_index) {}

  Cell& next() { return (Cell&)grid(next_index++, column_index); }
};

class Column : public Section {
private:
  const int column_index;

public:
  Column(const Grid& grid, int column_index)
      : Section(grid), column_index(column_index) {}

  ~Column() {}

  SectionIterator* get_iterator() {
    return new ColumnIterator(grid, column_index);
  }
};

} // namespace Sudoku

#endif // _SUDOKU_COLUMN_H_
