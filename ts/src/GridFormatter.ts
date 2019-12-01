import _ from 'lodash';
import Cell from './Cell';
import { N, B } from './core';

type CellStringifier = (c: Cell) => string;

export default class GridFormatter {
  private readonly stringifyCell: CellStringifier;

  private readonly top: string;
  private readonly bottom: string;
  private readonly middleMajor: string;
  private readonly middleMinor: string;

  constructor(cellContentWidth: number, stringifyCell: CellStringifier) {
    this.stringifyCell = stringifyCell;

    const cellWidth = cellContentWidth + 2;
    const nCellBorders = _.times(N, () => '═'.repeat(cellWidth));

    this.top = `╔${nCellBorders.join('╦')}╗`;
    this.bottom = `╚${nCellBorders.join('╩')}╝`;
    this.middleMajor = `\n╠${nCellBorders.join('╬')}╣\n`;
    this.middleMinor = `\n╠${_.times(B, () =>
      _.times(B, () => '─'.repeat(cellWidth)).join('┼')
    ).join('╬')}╣\n`;
  }

  public stringify(table: Cell[][]) {
    const inner = _.chain(table)
      .map(this.stringifyRow)
      .chunk(B)
      .map(rowBlock => rowBlock.join(this.middleMinor))
      .join(this.middleMajor)
      .value();

    return [this.top, inner, this.bottom].join('\n');
  }

  private stringifyRow = (row: Cell[]) =>
    _.chain(row)
      .chunk(B)
      .map(cellBlock => cellBlock.map(this.stringifyCell).join(' │ '))
      .join(' ║ ')
      .thru(innerRow => `║ ${innerRow} ║`)
      .value();
}
