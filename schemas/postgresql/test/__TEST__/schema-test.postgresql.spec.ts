import {
  sqlTestPackage,
  fakeTimers,
} from '@sqlpm/sqlpm-lib-ts';

describe('test schema', () => {
  fakeTimers();
  it('should successfully test the test schema', async () => {
    await sqlTestPackage(__dirname, 'test_test');
  });
});
