#include "State.h"
#include "Position.h"
#include "read_puzzle_file.h"

using namespace Sudoku;

State::State() : empty_cell_count(0) {
  for (int i = 0; i < N; i++) {
    rows[i] = new Row(grid, i);
    columns[i] = new Column(grid, i);
  }
  for (int i = 0; i < B; i++) {
    for (int j = 0; j < B; j++) {
      blocks[i][j] = new Block(grid, i, j);
    }
  }
}

State::~State() {
  for (int i = 0; i < N; i++) {
    delete rows[i];
    delete columns[i];
  }
  for (int i = 0; i < B; i++) {
    for (int j = 0; j < B; j++) {
      delete blocks[i][j];
    }
  }
}

void State::load_from_file(const std::string& filename) {
  int raw_grid[N][N];
  read_puzzle_file(filename, raw_grid);

  for (int row_index = 0; row_index < N; row_index++) {
    for (int column_index = 0; column_index < N; column_index++) {
      cell_t value = raw_grid[row_index][column_index];
      if (value) {
        place(value, Position(row_index, column_index));
      }
    }
  }
}

void State::place(cell_t value, const Position& position) {
  grid(position).place(value);

  row(position).place(value);
  column(position).place(value);
  block(position).place(value);

  empty_cell_count--;
}
