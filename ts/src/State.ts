import fs from 'fs-extra';
import _ from 'lodash';
import { B, N } from './core';
import Grid from './Grid';
import GridPosition from './GridPosition';
import { Block, Column, Row, Section } from './Sections';
import Cell from './Cell';

export default class State {
  grid: Grid;
  emptyCellCount: number;

  rows: Row[];
  columns: Column[];
  blocks: Block[][];

  constructor(source?: State) {
    if (source) {
      this.grid = source.grid.clone();
      this.emptyCellCount = source.emptyCellCount;

      this.rows = source.rows.map(row => row.clone(this.grid));
      this.columns = source.columns.map(column => column.clone(this.grid));
      this.blocks = source.blocks.map(blockRow =>
        blockRow.map(block => block.clone(this.grid))
      );
    } else {
      this.grid = new Grid();
      this.emptyCellCount = N * N;

      this.rows = _.times(N, i => new Row(this.grid, i));
      this.columns = _.times(N, i => new Column(this.grid, i));
      this.blocks = _.times(B, br =>
        _.times(B, bc => new Block(this.grid, br, bc))
      );
    }
  }

  clone() {
    return new State(this);
  }

  public loadFromFile(filename: string) {
    const rawTable = _.chain(fs.readFileSync(filename, 'utf-8'))
      .split('\n')
      .map(line => line.split('').map(toCellValue))
      .value();

    this.grid.eachPosition(position => {
      const value = rawTable[position.row][position.column];
      if (value) {
        this.place(value, position);
      }
    });
  }

  public eachCell(fn: (c: Cell, p: GridPosition) => any) {
    this.grid.eachPosition(position => fn(this.grid.cell(position), position));
  }

  public eachSection(fn: (s: Section) => any) {
    this.eachRow(fn);
    this.eachColumn(fn);
    this.eachBlock(fn);
  }

  public eachRow(fn: (r: Row) => any) {
    this.rows.forEach(fn);
  }

  public eachColumn(fn: (c: Column) => any) {
    this.columns.forEach(fn);
  }

  public eachBlock(fn: (b: Block) => any) {
    this.blocks.forEach(blockRow => blockRow.forEach(fn));
  }

  public place(value: number, position: GridPosition) {
    this.grid.cell(position).place(value);

    this.sectionsForPosition(position).forEach(section => section.place(value));

    this.emptyCellCount--;
  }

  sectionsForPosition = (position: GridPosition) => [
    this.row(position),
    this.column(position),
    this.block(position),
  ];

  row = (position: GridPosition) => this.rows[position.row];
  column = (position: GridPosition) => this.columns[position.column];
  block = (position: GridPosition) =>
    this.blocks[blockIndex(position.row)][blockIndex(position.column)];
}

function blockIndex(index: number) {
  return Math.floor(index / B);
}

function toCellValue(char: string) {
  return char.match(/\s+/) ? null : _.toNumber(char);
}
