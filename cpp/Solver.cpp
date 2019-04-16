#include "Solver.h"
#include "Position.h"
#include <set>
#include <string>
#include <vector>

using namespace std;
using namespace Sudoku;

void Solver::solve() {
  int placements_made;

  do {
    int initial_empty_count = empty_cell_count();

    solve_determined();
    if (!complete()) {
      eliminate_candidates_by_partial_determination();
    }

    placements_made = initial_empty_count - empty_cell_count();
  } while (!complete() && placements_made > 0);
}

void Solver::solve_determined() {
  int placements_made;

  do {
    int initial_empty_count = empty_cell_count();

    exhaustively_fill_determined_cells();
    exhaustively_fill_determined_positions();

    placements_made = initial_empty_count - empty_cell_count();
  } while (!complete() && placements_made > 0);
}

void Solver::exhaustively_fill_determined_cells() {
  int placements_made;

  do {
    int initial_empty_count = empty_cell_count();

    fill_determined_cells();

    placements_made = initial_empty_count - empty_cell_count();
  } while (!complete() && placements_made > 0);
}

void Solver::exhaustively_fill_determined_positions() {
  int placements_made;

  do {
    int initial_empty_count = empty_cell_count();

    fill_determined_positions();

    placements_made = initial_empty_count - empty_cell_count();
  } while (!complete() && placements_made > 0);
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
        if (block.has(value)) {
          continue;
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

        bool row_determined = candidate_rows.size() == 1;
        bool column_determined = candidate_columns.size() == 1;

        int determined_row_index = *candidate_rows.begin();
        int determined_column_index = *candidate_columns.begin();
        Position position(determined_row_index, determined_column_index);

        if (row_determined && column_determined) {
          sudoku.place(value, position);
        } else if (row_determined) {
          Row& row = sudoku.row(position);
          SectionIterator* row_iterator = row.get_iterator();

          while (!row_iterator->done()) {
            Position position = row_iterator->next_position();

            if (!block.includes(position)) {
              sudoku.cell(position).eliminate_candidate(value);
            }
          }

          delete row_iterator;
        } else if (column_determined) {
          Column& column = sudoku.column(position);
          SectionIterator* column_iterator = column.get_iterator();

          while (!column_iterator->done()) {
            Position position = column_iterator->next_position();

            if (!block.includes(position)) {
              sudoku.cell(position).eliminate_candidate(value);
            }
          }

          delete column_iterator;
        }
      }
    }
  }
}
