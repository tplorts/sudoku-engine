import _ from 'lodash';
import { CellOccupant, N } from './core';
import BitArray from './BitArray';

const ALL_VALUES = _.range(1, N + 1);

export default class Cell {
  occupant: CellOccupant = null;
  candidates = new BitArray(true);

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
  }

  candidateCount() {
    return _.sumBy(ALL_VALUES, n => (this.isCandidate(n) ? 1 : 0));
  }

  firstCandidate() {
    const candidate = _.find(ALL_VALUES, n => this.isCandidate(n));
    if (_.isNil(candidate)) {
      throw Error(); // TODO
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
