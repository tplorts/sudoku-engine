#include "Section.h"
#include "common.h"

using namespace Sudoku;

void Section::place(const cell_t value) {
  has_map[value] = true;

  each_cell([value](Cell& cell) { cell.eliminate_candidate(value); });
}

void Section::each_cell(CellFunction operate) const {
  each_position([this, operate](const Position& position) {
    operate((Cell&)grid(position));
  });
}

void Section::each_cell_with_position(CellPositionFunction operate) const {
  each_position([this, operate](const Position& position) {
    operate((Cell&)grid(position), position);
  });
}
