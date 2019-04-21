import _ from 'lodash';
import BitArray from './BitArray';
import Cell from './Cell';
import { N, B } from './core';
import Grid from './Grid';
import GridPosition from './GridPosition';

export abstract class Section {
  protected hasMap = new BitArray();
  protected grid: Grid;

  constructor(grid: Grid) {
    this.grid = grid;
  }

  public abstract eachPosition(fn: (p: GridPosition) => any): void;

  public eachCell(fn: (c: Cell, p: GridPosition) => any) {
    this.eachPosition(position => fn(this.grid.cell(position), position));
  }

  public has = (value: number) => this.hasMap.get(value);

  public place(value: number) {
    this.hasMap.set(value, true);
    this.eachCell(cell => cell.eliminateCandidate(value));
  }
}

export abstract class LinearSection extends Section {
  protected index: number;

  constructor(grid: Grid, index: number) {
    super(grid);
    this.index = index;
  }
}

export class Row extends LinearSection {
  public eachPosition(fn: (p: GridPosition) => any): void {
    _.times(N, columnIndex => fn(new GridPosition(this.index, columnIndex)));
  }
}

export class Column extends LinearSection {
  public eachPosition(fn: (p: GridPosition) => any): void {
    _.times(N, rowIndex => fn(new GridPosition(rowIndex, this.index)));
  }
}

export class Block extends Section {
  baseRowIndex: number;
  baseColumnIndex: number;

  constructor(grid: Grid, blockRowIndex: number, blockColumnIndex: number) {
    super(grid);
    this.baseRowIndex = blockRowIndex * B;
    this.baseColumnIndex = blockColumnIndex * B;
  }

  public eachPosition(fn: (p: GridPosition) => any): void {
    _.times(B, rowOffset =>
      _.times(B, columnOffset => fn(this.position(rowOffset, columnOffset)))
    );
  }

  private position(rowOffset: number, columnOffset: number) {
    return new GridPosition(
      this.baseRowIndex + rowOffset,
      this.baseColumnIndex + columnOffset
    );
  }

  public includes(position: GridPosition) {
    return (
      isInBlockRange(this.baseRowIndex, position.row) &&
      isInBlockRange(this.baseColumnIndex, position.column)
    );
  }
}

function isInBlockRange(blockBase: number, indexInQuestion: number) {
  return blockBase <= indexInQuestion && indexInQuestion < blockBase + B;
}
