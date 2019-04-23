import _ from 'lodash';
import Cell from './Cell';
import { N } from './core';
import GridFormatter from './GridFormatter';
import GridPosition from './GridPosition';

const standardFormatter = new GridFormatter(1, cell => cell.toString());
const verboseFormatter = new GridFormatter(N, cell => cell.toVerboseString());

export default class Grid {
  private table: Cell[][];

  constructor(source?: Grid) {
    const createCell = source
      ? (r: number, c: number) => source.cell(new GridPosition(r, c)).clone()
      : () => new Cell();

    this.table = _.times(N, r => _.times(N, c => createCell(r, c)));
  }

  clone() {
    return new Grid(this);
  }

  cell = (position: GridPosition) => this.table[position.row][position.column];

  eachPosition(fn: (p: GridPosition) => any): void {
    _.times(N, ri => _.times(N, ci => fn(new GridPosition(ri, ci))));
  }

  toString = () => standardFormatter.stringify(this.table);
  toVerboseString = () => verboseFormatter.stringify(this.table);
}
