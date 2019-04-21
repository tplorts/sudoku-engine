import _ from 'lodash';
import { ALL_VALUES } from './core';
import GridPosition from './GridPosition';
import { Block, LinearSection, Section } from './Sections';
import State from './State';

export interface SolverOptions {
  debugOutputEnabled?: boolean;
  debugValidationEnabled?: boolean;
}

const defaultOptions: SolverOptions = {
  debugOutputEnabled: false,
  debugValidationEnabled: false,
};

export default class Solver {
  readonly state: State;
  private options: SolverOptions;
  private nestingDepth = 0;

  constructor(filename: string, options = defaultOptions) {
    this.options = {
      ...defaultOptions,
      ...options,
    };

    this.state = new State();
    this.state.loadFromFile(filename);
  }

  emptyCount = () => this.state.emptyCellCount;
  isComplete = () => this.emptyCount() === 0;

  place(n: number, position: GridPosition) {
    this.log(`Placing ${n} in ${position}`);
    this.state.place(n, position);
  }

  log(message: string) {
    if (this.options.debugOutputEnabled) {
      const indentation = ' >'.repeat(this.nestingDepth) + ' ';
      const nestedMessage = message
        .split('\n')
        .map(line => indentation + line)
        .join('\n');
      console.log(nestedMessage);
    }
  }

  solve() {
    this.untilCompleteOrStuck(() => {
      this.solveDetermined();

      if (!this.isComplete()) {
        this.log(this.state.grid.toVerboseString());
        this.eliminateCandidatesByPartialDetermination();
      }
    }, 'solve');
  }

  solveDetermined() {
    this.untilCompleteOrStuck(() => {
      this.exhaustivelyFillDeterminedCells();
      this.exhaustivelyFillDeterminedPositions();
    }, 'solveDetermined');
  }

  /**
   * Repeatedly sweep the grid to find & fill determined cells.  With every
   * sweep, if any placements are made, then some other cells’ candidates may
   * have changed; that is why we repeat the find & fill sweeps until a full
   * sweep makes no placements.
   */
  exhaustivelyFillDeterminedCells() {
    this.untilCompleteOrStuck(
      this.fillDeterminedCells,
      'exhaustivelyFillDeterminedCells'
    );
  }

  /**
   * Perform one sweep across the whole grid, looking for unoccupied cells who
   * have only one candidate value (i.e. determined).  Fill in the determined
   * value in any such cells.
   */
  fillDeterminedCells = () => {
    this.state.eachCell((cell, position) => {
      if (cell.isUnoccupied() && cell.isDetermined()) {
        this.place(cell.firstCandidate(), position);
      }
    });
  };

  exhaustivelyFillDeterminedPositions() {
    this.untilCompleteOrStuck(
      this.fillDeterminedPositions,
      'exhaustivelyFillDeterminedPositions'
    );
  }

  fillDeterminedPositions = () => {
    ALL_VALUES.forEach(this.fillDeterminedPositionsForValue);
  };

  /**
   * Perform one sweep across the whole grid, looking for rows, columns, &
   * blocks in which there is exactly one place to put the value `n`, and make
   * such placements when found.
   */
  fillDeterminedPositionsForValue = (n: number) => {
    this.state.eachSection(section =>
      this.fillDeterminedPositionsForValueIn(n, section)
    );
  };

  fillDeterminedPositionsForValueIn = (n: number, section: Section) => {
    const candidatePositions = this.findCandidatePositions(n, section);
    if (candidatePositions.length === 1) {
      this.log(`${section} position determination`);
      this.place(n, candidatePositions[0]);
    }
  };

  /**
   * Assemble a list of positions in `section` in which the value `n` could be
   * placed.  _(recall: `section` could be a block, row, or column.)_
   * If `section` already has `n`, this will return an empty list.  If `section`
   * does not alreday have `n`, then the list will contain the positions from
   * within `section` whose cell is unoccupied and whose row, column, & block
   * all do not yet have `n`.
   */
  findCandidatePositions(n: number, section: Section) {
    const candidatePositions = [] as GridPosition[];

    if (!section.has(n)) {
      section.eachCell((cell, position) => {
        if (cell.isUnoccupied() && !this.anySectionsHave(position, n)) {
          candidatePositions.push(position);
        }
      });
    }

    return candidatePositions;
  }

  anySectionsHave(position: GridPosition, n: number) {
    const sections = this.state.sectionsForPosition(position);
    return _.some(sections, section => section.has(n));
  }

  eliminateCandidatesByPartialDetermination() {
    this.state.eachBlock(block => {
      ALL_VALUES.forEach(n => {
        if (block.has(n)) return;

        const [
          determinedRowIndex,
          determinedColumnIndex,
        ] = this.findDeterminedRowColumnInBlock(n, block);

        const position = new GridPosition(
          determinedRowIndex || 0,
          determinedColumnIndex || 0
        );

        if (!_.isNil(determinedRowIndex) && !_.isNil(determinedColumnIndex)) {
          this.place(n, position);
        } else if (!_.isNil(determinedRowIndex)) {
          const row = this.state.row(position);
          this.eliminateCandidateInSectionExceptInBlock(n, row, block);
        } else if (!_.isNil(determinedColumnIndex)) {
          const column = this.state.column(position);
          this.eliminateCandidateInSectionExceptInBlock(n, column, block);
        }
      });
    });
  }

  findDeterminedRowColumnInBlock(n: number, block: Block) {
    const candidateRows = new Set<number>();
    const candidateColumns = new Set<number>();

    block.eachCell((cell, position) => {
      if (cell.isCandidate(n)) {
        candidateRows.add(position.row);
        candidateColumns.add(position.column);
      }
    });

    return [onlyValueOrNull(candidateRows), onlyValueOrNull(candidateColumns)];
  }

  eliminateCandidateInSectionExceptInBlock(
    candidateValue: number,
    section: LinearSection,
    block: Block
  ) {
    section.eachCell((cell, position) => {
      if (!block.includes(position)) {
        if (cell.isCandidate(candidateValue)) {
          this.log(`eliminate ${candidateValue} from ${position}`);
        }
        cell.eliminateCandidate(candidateValue);
      }
    });
  }

  private untilCompleteOrStuck(operate: Function, label: string = '') {
    let isStuck = false;
    this.nestingDepth++;
    this.log('Begin ' + label);

    while (!this.isComplete() && !isStuck) {
      const initialEmptyCount = this.emptyCount();

      operate();

      isStuck = this.emptyCount() === initialEmptyCount;
    }
    this.log('End ' + label);
    this.nestingDepth--;
  }
}

function onlyValueOrNull<T>(set: Set<T>) {
  return set.size == 1 ? set.values().next().value : null;
}
