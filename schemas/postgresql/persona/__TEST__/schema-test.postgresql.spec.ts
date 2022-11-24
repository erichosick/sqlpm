import {
  sqlTestPackage,
  fakeTimers,
} from '@sqlpm/sqlpm-lib-ts';

describe('persona schema', () => {
  fakeTimers();
  it('should successfully create schema persona', async () => {
    // To keep generated sql packages amd database around after the test, set
    // keepGenerated to true: false by default as seen below.
    const result = await sqlTestPackage(
      __dirname,
      'persona_test',
      { keepGenerated: false },
    );
    expect(result).toEqual(true);
  });
});
