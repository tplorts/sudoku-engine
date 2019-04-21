export default class GridPosition {
  readonly row: number;
  readonly column: number;

  constructor(row: number, column: number) {
    this.row = row;
    this.column = column;
  }

  toString() {
    return `(${this.row},${this.column})`;
  }
}
