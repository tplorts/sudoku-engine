import _ from 'lodash';
import Solver from './Solver';

function measureDurationMilliseconds(operate: Function) {
  const startTime = process.hrtime();
  operate();
  const [seconds, nanoseconds] = process.hrtime(startTime);
  return seconds * 1e3 + nanoseconds * 1e-6;
}

const N = 100;

const averageDuration = _.chain(N)
  .times()
  .map(() => {
    const solver = new Solver(null);
    return measureDurationMilliseconds(() => solver.solve());
  })
  .sum()
  .thru(sum => sum / N)
  .value();

console.info(`average duration of 100 generations: ${averageDuration} ms`);
