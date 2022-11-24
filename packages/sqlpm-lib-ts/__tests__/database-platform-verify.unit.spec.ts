import {
  databasePlatformVerify,
} from '@sqlpm/types-ts';

describe('databasePlatformVerify', () => {
  it(`should return true when the value provided
    is in the databasePlatform enum`, () => {
    expect(databasePlatformVerify('postgresql')).toEqual(true);
  });

  it(`should return false when the value provided
    is in the databasePlatform enum`, () => {
    expect(databasePlatformVerify('not')).toEqual(false);
  });
});
