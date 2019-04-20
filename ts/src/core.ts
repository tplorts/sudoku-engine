import _ from 'lodash';

export const B = 3;
export const N = B * B;

export type CellOccupant = number | null;

export const ALL_VALUES = _.range(1, N + 1);
