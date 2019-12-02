import _ from 'lodash';
import { ALL_VALUES, N } from './core';
import Cell from './Cell';
import GridPosition from './GridPosition';
import { Block, LinearSection, Section } from './Sections';
import State from './State';

export interface SolverOptions {
  debugOutputEnabled?: boolean;
  debugValidationEnabled?: boolean;
  shuffleCandidateValues?: boolean;
}

const defaultOptions: SolverOptions = {
  debugOutputEnabled: false,
  debugValidationEnabled: false,
  shuffleCandidateValues: false,
};

export default class Solver {
  state: State;
  private options: SolverOptions;
  private searchDepth = 0;
  private nestingDepth = 0;

  constructor(
    filename: string | null,
    options = defaultOptions,
    source?: Solver
  ) {
    this.options = {
      ...defaultOptions,
      ...options,
    };

    if (source) {
      this.state = source.state.clone();
      this.searchDepth = source.searchDepth + 1;
    } else {
      this.state = new State();
      if (filename) {
        this.state.loadFromFile(filename);
      } else {
        this.options.shuffleCandidateValues = true;
      }
    }
  }

  static generate() {
    const engine = new Solver(null);
    engine.solve();
    return engine.state;
  }

  clone() {
    return new Solver('', this.options, this);
  }

  emptyCount = () => this.state.emptyCellCount;
  isComplete = () => this.emptyCount() === 0;

  place(n: number, position: GridPosition) {
    // this.log(`placing ${n} in ${position}`);
    this.state.place(n, position);
    // this.log(this.state.grid.toVerboseString());
  }

  log(message: string) {
    if (this.options.debugOutputEnabled) {
      const indentation = '> '.repeat(this.searchDepth);
      // + '#'.repeat(this.nestingDepth) + ' ';
      const nestedMessage = message
        .split('\n')
        .map(line => indentation + line)
        .join('\n');
      console.log(nestedMessage);
    }
  }

  solve() {
    this.log(`begin solve with ${this.emptyCount()} left`);

    this.untilCompleteOrStuck(() => {
      this.solveDetermined();

      if (!this.isComplete()) {
        // this.log(this.state.grid.toVerboseString());
        this.eliminateCandidatesByPartialDetermination();
      }
    }, 'solve');

    this.log(`end determined solve with ${this.emptyCount()} left`);

    if (this.isComplete()) {
      return this;
    } else {
      if (this.searchDepth == 0) {
        this.log('the following state is sound, before guessing begins:');
        this.log(this.state.grid.toVerboseString());
      }
    }

    const seedPosition = this.positionWithFewestCandidates();
    const seedCell = this.state.grid.cell(seedPosition);

    for (const candidateValue of this.getCandidateValues(seedCell)) {
      const child = this.clone();

      child.log(`guessing ${candidateValue} in ${seedPosition}`);
      child.place(candidateValue, seedPosition);
      try {
        child.solve();
        if (child.isComplete()) {
          this.state = child.state;
          return this;
        }
      } catch (error) {
        child.log('abandoning branch; final branch state, with contradiction:');
        child.log(child.state.grid.toVerboseString());
        this.log('picking up from here:');
        this.log(this.state.grid.toVerboseString());
      }
    }

    return null;
  }

  getCandidateValues(cell: Cell) {
    const values = cell.candidateValues();
    return this.options.shuffleCandidateValues ? _.shuffle(values) : values;
  }

  positionWithFewestCandidates() {
    let fewestCandidates = N + 1;
    let chosenPosition: GridPosition | null = null;

    this.state.eachCell((cell, position) => {
      if (cell.isOccupied()) return;
      const candidateCount = cell.candidateCount();
      if (cell.isUnoccupied() && candidateCount < fewestCandidates) {
        chosenPosition = position;
        fewestCandidates = candidateCount;
      }
    });

    if (!chosenPosition) {
      throw new Error();
    }

    return chosenPosition;
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

  /**
   * Perform one sweep per value across the whole grid, looking for rows,
   * columns, & blocks in which there is exactly one place to put the value `n`,
   * and make such placements when found.
   */
  fillDeterminedPositions = () => {
    ALL_VALUES.forEach(n => {
      this.state.eachSection(section => {
        const candidatePositions = this.findCandidatePositions(n, section);
        if (candidatePositions.length === 1) {
          // this.log(`${section} position determination`);
          this.place(n, candidatePositions[0]);
        }
      });
    });
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
        // if (cell.isCandidate(candidateValue)) {
        //   this.log(`eliminate ${candidateValue} from ${position}`);
        // }
        cell.eliminateCandidate(candidateValue);
      }
    });
  }

  private untilCompleteOrStuck(operate: Function, label: string = '') {
    let isStuck = false;
    this.nestingDepth++;
    // this.log('Begin ' + label);

    while (!this.isComplete() && !isStuck) {
      const initialEmptyCount = this.emptyCount();

      operate();

      isStuck = this.emptyCount() === initialEmptyCount;
    }
    // this.log('End ' + label);
    this.nestingDepth--;
  }
}

function onlyValueOrNull<T>(set: Set<T>) {
  return set.size == 1 ? set.values().next().value : null;
}
