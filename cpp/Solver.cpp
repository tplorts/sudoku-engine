#include "Solver.h"
#include "Position.h"
#include <algorithm>
#include <iostream>
#include <set>
#include <string>
#include <vector>

using namespace std;
using namespace Sudoku;

State Solver::generate() {
  Solver engine;
  engine.solve();
  return *engine.state;
}

void Solver::solve() {
  until_complete_or_stuck([this]() {
    solve_determined();
    if (!complete()) {
      eliminate_candidates_by_partial_determination();
    }
  });

  if (complete()) {
    return;
  }

  const Position seed_position = position_with_fewest_candidates();
  const Cell& seed_cell = state->cell(seed_position);

  for (cell_t candidate_value : get_candidate_values(seed_cell)) {
    Solver child(*this);
    child.place(candidate_value, seed_position);
    try {
      child.solve();
      if (child.complete()) {
        delete state;
        state = child.state;
        child.state = NULL;
        return;
      }
    } catch (const CellContradiction& e) {
    }
  }
}

vector<cell_t> Solver::get_candidate_values(const Cell& cell) {
  return shuffle_candidate_values ? cell.shuffled_candidate_values()
                                  : cell.candidate_values();
}

Position Solver::position_with_fewest_candidates() {
  int fewest_candidates = N + 1;
  Position chosen_position(0, 0);

  for (int row_index = 0; row_index < N; row_index++) {
    for (int column_index = 0; column_index < N; column_index++) {
      Position position(row_index, column_index);
      Cell& cell = state->cell(position);

      int candidate_count = cell.candidate_count();
      if (!cell.occupied() && candidate_count < fewest_candidates) {
        chosen_position = position;
        fewest_candidates = candidate_count;
      }
    }
  }

  return chosen_position;
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
      Cell& cell = state->cell(position);

      if (cell.determined()) {
        place(cell.first_candidate(), position);
      }
    }
  }
}

void Solver::fill_determined_positions() {
  for (int value = 1; value <= N; value++) {
    state->each_section([value, this](Section& section) {
      vector<Position> candidate_positions =
          find_candidate_positions(value, section);

      if (candidate_positions.size() == 1) {
        place(value, candidate_positions[0]);
      }
    });
    for (int block_row_index = 0; block_row_index < B; block_row_index++) {
      for (int block_column_index = 0; block_column_index < B;
           block_column_index++) {
        Block& block = state->block(block_row_index, block_column_index);
        vector<Position> candidate_positions =
            find_candidate_positions(value, block);

        if (candidate_positions.size() == 1) {
          place(value, candidate_positions[0]);
        }
      }
    }
  }
}

vector<Position> Solver::find_candidate_positions(int value,
                                                  const Section& section) {
  vector<Position> candidates;

  if (section.has(value)) {
    return candidates;
  }

  section.each_cell_with_position(
      [&](Cell& cell, const Position& position) mutable {
        if (!cell.occupied() && !any_sections_have(position, value)) {
          candidates.push_back(position);
        }
      });

  return candidates;
}

bool Solver::any_sections_have(const Position& position, int value) {
  const auto sections = state->sections_for_position(position);

  return any_of(sections.begin(), sections.end(),
                [value](Section* s) { return s->has(value); });
}

void Solver::eliminate_candidates_by_partial_determination() {
  for (int block_row_index = 0; block_row_index < B; block_row_index++) {
    for (int block_column_index = 0; block_column_index < B;
         block_column_index++) {
      Block& block = state->block(block_row_index, block_column_index);

      for (int value = 1; value <= N; value++) {
        Position position = find_determined_row_column_in_block(value, block);

        if (position.is_row_determined() && position.is_column_determined()) {
          place(value, position);
        } else if (position.is_row_determined()) {
          const Row& row = state->row(position);
          eliminate_candidate_in_section_except_in_block(value, row, block);
        } else if (position.is_column_determined()) {
          const Column& column = state->column(position);
          eliminate_candidate_in_section_except_in_block(value, column, block);
        }
      }
    }
  }
}

int only_value_or_undetermined(set<int> indices) {
  return indices.size() == 1 ? *indices.begin() : UNDETERMINED_INDEX;
}

Position Solver::find_determined_row_column_in_block(int value,
                                                     const Block& block) {
  if (block.has(value)) {
    return Position::undetermined();
  }

  set<int> candidate_rows;
  set<int> candidate_columns;

  block.each_cell_with_position(
      [&](Cell& cell, const Position& position) mutable {
        if (cell.is_candidate(value)) {
          candidate_rows.insert(position.row());
          candidate_columns.insert(position.column());
        }
      });

  return Position(only_value_or_undetermined(candidate_rows),
                  only_value_or_undetermined(candidate_columns));
}

void Solver::eliminate_candidate_in_section_except_in_block(
    int value, const Section& section, const Block& block) {

  section.each_cell_with_position([&](Cell& cell, const Position& position) {
    if (!block.includes(position)) {
      cell.eliminate_candidate(value);
    }
  });
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