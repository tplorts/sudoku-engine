import _ from 'lodash';
import BitArray from './BitArray';
import { ALL_VALUES, CellOccupant } from './core';

const NO_CANDIDATES_NO_OCCUPANT = new BitArray();
NO_CANDIDATES_NO_OCCUPANT.set(0, true);

export default class Cell {
  occupant: CellOccupant = null;
  candidates = new BitArray(true);

  clone() {
    const cell = new Cell();
    cell.occupant = this.occupant;
    cell.candidates = this.candidates.clone();
    return cell;
  }

  place(value: number) {
    this.occupant = value;
    this.candidates = new BitArray(false);
  }

  isUnoccupied = () => this.occupant === null;
  isOccupied = () => !this.isUnoccupied();
  isCandidate = (n: number) => this.candidates.get(n);
  isDetermined = () => this.candidateCount() === 1;

  eliminateCandidate(value: number) {
    this.candidates.set(value, false);
    if (this.candidates.equals(NO_CANDIDATES_NO_OCCUPANT)) {
      throw new Error();
    }
  }

  candidateCount() {
    return _.sumBy(ALL_VALUES, n => (this.isCandidate(n) ? 1 : 0));
  }

  candidateValues() {
    return _.filter(ALL_VALUES, n => this.isCandidate(n));
  }

  firstCandidate() {
    const candidate = _.find(ALL_VALUES, n => this.isCandidate(n));
    if (_.isNil(candidate)) {
      throw new Error();
    }
    return Number(candidate);
  }

  toString() {
    return this.isOccupied() ? String(this.occupant) : ' ';
  }

  toVerboseString() {
    return this.isOccupied()
      ? `░░░ ${this.occupant} ░░░`
      : this.candidatesString();
  }

  candidatesString() {
    const stringForCandidate = (n: number) =>
      this.isCandidate(n) ? n.toString() : ' ';

    return ALL_VALUES.map(stringForCandidate).join('');
  }
}
