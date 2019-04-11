#if !defined(_SUDOKU_STATE_H_)
#define _SUDOKU_STATE_H_

#include "Block.h"
#include "Column.h"
#include "Grid.h"
#include "Row.h"
#include <iostream>
#include <string>

namespace Sudoku {

class State {
private:
  Grid grid;
  int empty_cell_count;

  Row *rows[N];
  Column *columns[N];
  Block *blocks[B][B];

public:
  State();
  ~State();

  void load_from_file(const std::string &filename);

  Cell &get_cell(int row_index, int column_index) {
    return grid(row_index, column_index);
  }

  int get_empty_cell_count() const { return empty_cell_count; }

  void place(cell_t value, int row_index, int column_index);

  Row &row(int row_index) { return *rows[row_index]; }

  Column &column(int column_index) { return *columns[column_index]; }

  Block &block(int row_index, int column_index) {
    return *blocks[row_index / B][column_index / B];
  }

  friend std::ostream &operator<<(std::ostream &outs, const State &sudoku) {
    return outs << sudoku.grid;
  }
};

} // namespace Sudoku

#endif // _SUDOKU_STATE_H_
