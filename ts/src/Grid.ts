import _ from 'lodash';
import Cell from './Cell';
import { N } from './core';
import GridFormatter from './GridFormatter';
import GridPosition from './GridPosition';

const standardFormatter = new GridFormatter(1, cell => cell.toString());
const verboseFormatter = new GridFormatter(N, cell => cell.toVerboseString());

export default class Grid {
  private table: Cell[][];

  constructor() {
    this.table = _.times(N, () => _.times(N, () => new Cell()));
  }

  cell = (position: GridPosition) => this.table[position.row][position.column];

  eachPosition(fn: (p: GridPosition) => any): void {
    _.times(N, ri => _.times(N, ci => fn(new GridPosition(ri, ci))));
  }

  toString = () => standardFormatter.stringify(this.table);
  toVerboseString = () => verboseFormatter.stringify(this.table);
}
