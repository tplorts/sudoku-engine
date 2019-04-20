import { ALL_VALUES } from './core';
import GridPosition from './GridPosition';
import { Block } from './Sections';
import State from './State';

export interface SolverOptions {
  debugOutputEnabled: boolean;
  debugValidationEnabled: boolean;
}

const defaultOptions: SolverOptions = {
  debugOutputEnabled: false,
  debugValidationEnabled: false,
};

export default class Solver {
  private options: SolverOptions;
  readonly state: State;

  constructor(filename: string, options = defaultOptions) {
    this.options = options;

    this.state = new State();
    this.state.loadFromFile(filename);
  }

  public solve() {
    this.solveDetermined();
  }

  emptyCount = () => this.state.emptyCellCount;
  isComplete = () => this.emptyCount() === 0;

  solveDetermined() {
    this.untilCompleteOrStuck(() => {
      this.exhaustivelyFillDeterminedCells();
      this.exhaustivelyFillDeterminedPositions();
    });
  }

  /**
   * Repeatedly sweep the grid to find & fill determined cells.  With every
   * sweep, if any placements are made, then some other cells’ candidates may
   * have changed; that is why we repeat the find & fill sweeps until a full
   * sweep makes no placements.
   */
  exhaustivelyFillDeterminedCells() {
    this.untilCompleteOrStuck(this.fillDeterminedCells);
  }

  /**
   * Perform one sweep across the whole grid, looking for unoccupied cells who
   * have only one candidate value (i.e. determined).  Fill in the determined
   * value in any such cells.
   */
  fillDeterminedCells = () => {
    this.state.eachCell((cell, position) => {
      if (cell.isUnoccupied() && cell.isDetermined()) {
        this.state.place(cell.firstCandidate(), position);
      }
    });
  };

  exhaustivelyFillDeterminedPositions() {
    this.untilCompleteOrStuck(this.fillDeterminedPositions);
  }

  fillDeterminedPositions = () => {
    ALL_VALUES.forEach(this.fillDeterminedPositionsForValue);
  };

  /**
   * Perform one sweep across the whol grid, looking for blocks in which there
   * is exactly one place to put the value n, and make such placements when
   * found.
   */
  fillDeterminedPositionsForValue = (n: number) => {
    this.state.eachBlock(block => {
      const candidatePositions = this.findCandidatePositions(n, block);
      if (candidatePositions.length === 1) {
        this.state.place(n, candidatePositions[0]);
      }
    });
  };

  /**
   * Assemble a list of positions in block in which the value n could be placed.
   * If the block already has n, this will return an empty list.  If the block
   * does not alreday have n, then the list will contain the positions from
   * within the block whose cell is unoccupied and whose row and column do not
   * have n yet.
   */
  findCandidatePositions(n: number, block: Block) {
    const candidatePositions = [] as GridPosition[];

    if (!block.has(n)) {
      block.eachCell((cell, position) => {
        if (
          cell.isUnoccupied() &&
          !this.state.row(position).has(n) &&
          !this.state.column(position).has(n)
        ) {
          candidatePositions.push(position);
        }
      });
    }

    return candidatePositions;
  }

  private untilCompleteOrStuck(operate: Function) {
    let isStuck = false;

    while (!this.isComplete() && !isStuck) {
      const initialEmptyCount = this.emptyCount();

      operate();

      isStuck = this.emptyCount() === initialEmptyCount;
    }
  }
}
