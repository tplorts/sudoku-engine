import Solver from './Solver';

const solver = new Solver(process.argv[2]);

console.log('initial state');
console.log(solver.state.grid.toVerboseString());

solver.solve();

console.log('done');
console.log(solver.state.grid.toString());

if (!solver.isComplete()) {
  console.log('could not complete the puzzle');
  console.log(solver.state.grid.toVerboseString());
}
