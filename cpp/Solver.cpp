#include "Solver.h"
#include "Position.h"
#include <set>
#include <string>
#include <vector>

using namespace std;
using namespace Sudoku;

void Solver::solve() {
  until_complete_or_stuck([this]() {
    solve_determined();
    if (!complete()) {
      eliminate_candidates_by_partial_determination();
    }
  });
}

void Solver::solve_determined() {
  until_complete_or_stuck([this]() {
    exhaustively_fill_determined_cells();
    exhaustively_fill_determined_positions();
  });
}

void Solver::exhaustively_fill_determined_cells() {
  until_complete_or_stuck([this]() { fill_determined_cells(); });
}

void Solver::exhaustively_fill_determined_positions() {
  until_complete_or_stuck([this]() { fill_determined_positions(); });
}

void Solver::fill_determined_cells() {
  for (int row_index = 0; row_index < N; row_index++) {
    for (int column_index = 0; column_index < N; column_index++) {
      Position position(row_index, column_index);
      Cell& cell = sudoku.cell(position);

      if (cell.determined()) {
        sudoku.place(cell.first_candidate(), position);
      }
    }
  }
}

void Solver::fill_determined_positions() {
  for (int value = 1; value <= N; value++) {
    for (int block_row_index = 0; block_row_index < B; block_row_index++) {
      for (int block_column_index = 0; block_column_index < B;
           block_column_index++) {
        Block& block = sudoku.block(block_row_index, block_column_index);
        vector<Position> candidate_positions =
            find_candidate_positions(value, block);

        if (candidate_positions.size() == 1) {
          sudoku.place(value, candidate_positions[0]);
        }
      }
    }
  }
}

vector<Position> Solver::find_candidate_positions(int value,
                                                  const Block& block) {
  vector<Position> candidates;

  if (block.has(value)) {
    return candidates;
  }

  SectionIterator* iterator = block.get_iterator();

  while (!iterator->done()) {
    Position position = iterator->next_position();
    Cell& cell = sudoku.cell(position);

    if (!cell.occupied() && !sudoku.row(position).has(value) &&
        !sudoku.column(position).has(value)) {
      candidates.push_back(position);
    }
  }

  delete iterator;

  return candidates;
}

void Solver::eliminate_candidates_by_partial_determination() {
  for (int block_row_index = 0; block_row_index < B; block_row_index++) {
    for (int block_column_index = 0; block_column_index < B;
         block_column_index++) {
      Block& block = sudoku.block(block_row_index, block_column_index);

      for (int value = 1; value <= N; value++) {
        Position position = find_determined_row_column_in_block(value, block);

        if (position.is_row_determined() && position.is_column_determined()) {
          sudoku.place(value, position);
        } else if (position.is_row_determined()) {
          const Row& row = sudoku.row(position);
          eliminate_candidate_in_section_except_in_block(value, row, block);
        } else if (position.is_column_determined()) {
          const Column& column = sudoku.column(position);
          eliminate_candidate_in_section_except_in_block(value, column, block);
        }
      }
    }
  }
}

Position Solver::find_determined_row_column_in_block(int value,
                                                     const Block& block) {
  if (block.has(value)) {
    return Position::undetermined();
  }

  set<int> candidate_rows;
  set<int> candidate_columns;

  SectionIterator* block_iterator = block.get_iterator();

  while (!block_iterator->done()) {
    Position position = block_iterator->next_position();

    if (sudoku.cell(position).is_candidate(value)) {
      candidate_rows.insert(position.row());
      candidate_columns.insert(position.column());
    }
  }

  delete block_iterator;

  return Position(candidate_rows.size() == 1 ? *candidate_rows.begin()
                                             : UNDETERMINED_INDEX,
                  candidate_columns.size() == 1 ? *candidate_columns.begin()
                                                : UNDETERMINED_INDEX);
}

void Solver::eliminate_candidate_in_section_except_in_block(
    int value, const Section& section, const Block& block) {
  SectionIterator* iterator = section.get_iterator();

  while (!iterator->done()) {
    Position position = iterator->next_position();

    if (!block.includes(position)) {
      sudoku.cell(position).eliminate_candidate(value);
    }
  }

  delete iterator;
}

template <typename Operation>
void Solver::until_complete_or_stuck(Operation operate) {
  bool stuck = false;

  while (!complete() && !stuck) {
    int initial_empty_count = empty_cell_count();

    operate();

    stuck = empty_cell_count() == initial_empty_count;
  }
}