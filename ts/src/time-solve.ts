import _ from 'lodash';
import fs from 'fs-extra';
import Solver from './Solver';

function measureDurationMilliseconds(operate: Function) {
  const startTime = process.hrtime();
  operate();
  const [seconds, nanoseconds] = process.hrtime(startTime);
  return seconds * 1e3 + nanoseconds * 1e-6;
}

const puzzles = _.chain(fs.readdirSync('../puzzles'))
  .map(entry => entry.match(/\d+([a-z])\.sudoku/))
  .compact()
  .map(([filename, difficulty]) => ({ filename, difficulty }))
  .value();

_.chain(100)
  .times(_.constant(puzzles))
  .flatten()
  .map(({ filename, difficulty }) => {
    const solver = new Solver(`../puzzles/${filename}`);
    const duration = measureDurationMilliseconds(() => solver.solve());
    return { difficulty, duration };
  })
  .groupBy('difficulty')
  .mapValues(timeList => _.sumBy(timeList, 'duration') / timeList.length)
  .mapValues(time => _.round(time, 3))
  .forEach((time, difficulty) => {
    console.info(`${difficulty}: ${time} ms`);
  })
  .value();
