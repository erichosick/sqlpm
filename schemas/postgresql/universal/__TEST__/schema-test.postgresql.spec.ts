import {
  sqlTestPackage,
  fakeTimers,
} from '@sqlpm/sqlpm-lib-ts';

describe('universal schema', () => {
  fakeTimers();
  jest.setTimeout(100000);
  it('should successfully create schema universal', async () => {
    // To keep generated sql packages around after the test, set
    // keepGenerated to true: false by default as seen below.
    const result = await sqlTestPackage(__dirname, 'universal_test', false);
    expect(result).toEqual(true);
  });
});
