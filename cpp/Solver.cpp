#include "Solver.h"
#include "Position.h"
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

void Solver::eliminate_candidates_by_partial_determination() {}
