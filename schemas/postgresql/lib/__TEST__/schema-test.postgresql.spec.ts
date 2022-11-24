import {
  sqlTestPackage,
  fakeTimers,
} from '@sqlpm/sqlpm-lib-ts';

describe('lib schema', () => {
  fakeTimers();
  it('should successfully create schema lib', async () => {
    // To keep generated sql packages around after the test, set
    // keepGenerated to true: false by default as seen below.
    const result = await sqlTestPackage(
      __dirname,
      'lib_test',
      { keepGenerated: false },
    );
    expect(result).toEqual(true);
  });
});
