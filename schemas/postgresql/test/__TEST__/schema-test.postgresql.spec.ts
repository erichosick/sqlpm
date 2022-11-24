import {
  sqlTestPackage,
  fakeTimers,
} from '@sqlpm/sqlpm-lib-ts';

describe('test schema', () => {
  fakeTimers();
  it('should successfully test the test schema', async () => {
    // To keep generated sql packages around after the test, set
    // keepGenerated to true: false by default as seen below.
    const result = await sqlTestPackage(
      __dirname,
      'test_test',
      { keepGenerated: false },
    );
    expect(result).toEqual(true);
  });
});
