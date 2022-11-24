import {
  sqlTestPackage,
} from '../src';

import {
  fakeTimers,
} from '../src/fake-timers';

describe('sqlTestPackage', () => {
  fakeTimers();

  it('should test a package', async () => {
    // To keep generated sql packages amd database around after the test, set
    // keepGenerated to true: false by default as seen below.
    const result = await sqlTestPackage(
      __dirname,
      'empty_database_test',
      { keepGenerated: false },
    );
    expect(result).toEqual(true);
  });
});
