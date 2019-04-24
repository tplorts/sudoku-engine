#if !defined(_SUDOKU_STATE_H_)
#define _SUDOKU_STATE_H_

#include "Block.h"
#include "Column.h"
#include "Grid.h"
#include "Position.h"
#include "Row.h"
#include <array>
#include <iostream>
#include <string>

namespace Sudoku {

typedef std::function<void(Section&)> SectionFunction;

class State {
private:
  static const int SECTIONS_PER_POSITION = 3;

  Grid grid;
  int empty_cell_count;

  Row* rows[N];
  Column* columns[N];
  Block* blocks[B][B];

public:
  State();
  State(const State& source);

  ~State();

  void load_from_file(const std::string& filename);

  Cell& cell(const Position& position) { return grid(position); }

  int get_empty_cell_count() const { return empty_cell_count; }

  void place(cell_t value, const Position& position);

  const std::array<Section*, SECTIONS_PER_POSITION>
  sections_for_position(const Position& position);

  void each_section(SectionFunction);

  Row& row(const Position& position) { return *rows[position.row()]; }

  Column& column(const Position& position) {
    return *columns[position.column()];
  }

  Block& block(int block_row_index, int block_column_index) {
    return *blocks[block_row_index][block_column_index];
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
