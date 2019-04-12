#if !defined(_SUDOKU_STATE_H_)
#define _SUDOKU_STATE_H_

#include "Block.h"
#include "Column.h"
#include "Grid.h"
#include "Position.h"
#include "Row.h"
#include <iostream>
#include <string>

namespace Sudoku {

class State {
private:
  Grid grid;
  int empty_cell_count;

  Row* rows[N];
  Column* columns[N];
  Block* blocks[B][B];

public:
  State();
  ~State();

  void load_from_file(const std::string& filename);

  Cell& get_cell(const Position& position) { return grid(position); }

  int get_empty_cell_count() const { return empty_cell_count; }

  void place(cell_t value, const Position& position);

  Row& row(const Position& position) { return *rows[position.row()]; }

  Column& column(const Position& position) {
    return *columns[position.column()];
  }

  Block& block(const Position& position) {
    return *blocks[position.block_row()][position.block_column()];
  }

  friend std::ostream& operator<<(std::ostream& outs, const State& sudoku) {
    return outs << sudoku.grid;
  }
};

} // namespace Sudoku

#endif // _SUDOKU_STATE_H_
