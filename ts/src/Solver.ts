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
    this.exhaustivelyFillDeterminedCells();
  }

  private emptyCount = () => this.state.emptyCellCount;

  isComplete = () => this.emptyCount() === 0;

  exhaustivelyFillDeterminedCells() {
    this.untilCompleteOrStuck(this.fillDeterminedCells);
  }

  fillDeterminedCells = () => {
    this.state.eachCell((cell, position) => {
      if (cell.isDetermined()) {
        this.state.place(cell.firstCandidate(), position);
      }
    });
  };

  private untilCompleteOrStuck(operate: Function) {
    let isStuck = false;

    while (!this.isComplete() && !isStuck) {
      const initialEmptyCount = this.emptyCount();

      operate();

      isStuck = this.emptyCount() === initialEmptyCount;
    }
  }
}
