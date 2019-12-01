import Solver from './Solver';

const solver = new Solver('../puzzles/20190220a.sudoku');

console.log('initial state');
console.log(solver.state.grid.toVerboseString());

solver.solve();

console.log('done');
console.log(solver.state.grid.toString());
