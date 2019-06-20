import * as A from './A';
import B from './B';

import sinon = require('sinon');

// Run  mocha -r ts-node/register tests/test.ts
describe('Constructor test', () => {
  it('Constructor test', () => {
    const spy = sinon.replace(
      A,
      'SomeOtherClass',
      sinon.fake.returns(() => console.log('I am called')),
    );

    new B().someFunction();
    console.log('count  ', spy.callCount);
  });
});
