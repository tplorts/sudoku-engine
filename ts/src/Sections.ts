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

  public abstract clone(newGrid: Grid): Section;

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
  clone(newGrid: Grid) {
    const row = new Row(newGrid, this.index);
    row.hasMap = this.hasMap.clone();
    return row;
  }

  public eachPosition(fn: (p: GridPosition) => any): void {
    _.times(N, columnIndex => fn(new GridPosition(this.index, columnIndex)));
  }

  public toString() {
    return `row ${this.index}`;
  }
}

export class Column extends LinearSection {
  clone(newGrid: Grid) {
    const column = new Column(newGrid, this.index);
    column.hasMap = this.hasMap.clone();
    return column;
  }

  public eachPosition(fn: (p: GridPosition) => any): void {
    _.times(N, rowIndex => fn(new GridPosition(rowIndex, this.index)));
  }

  public toString() {
    return `column ${this.index}`;
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

  clone(newGrid: Grid) {
    const block = new Block(newGrid, 0, 0);
    block.baseRowIndex = this.baseRowIndex;
    block.baseColumnIndex = this.baseColumnIndex;
    block.hasMap = this.hasMap.clone();
    return block;
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

  public toString() {
    return `block [${this.baseRowIndex / B},${this.baseColumnIndex / B}]`;
  }
}

function isInBlockRange(blockBase: number, indexInQuestion: number) {
  return blockBase <= indexInQuestion && indexInQuestion < blockBase + B;
}
