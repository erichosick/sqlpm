import {
  sqlTestPackage,
  fakeTimers,
} from '@sqlpm/sqlpm-lib-ts';

describe('lib schema', () => {
  fakeTimers();
  it('should successfully create schema lib', async () => {
    // To keep generated sql packages around after the test, set
    // keepGeneratedSql to true: false by default
    await sqlTestPackage(__dirname, 'lib_test', false);
  });
});
