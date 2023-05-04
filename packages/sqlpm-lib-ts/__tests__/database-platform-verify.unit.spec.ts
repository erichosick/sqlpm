import {
  databaseSystemVerify,
} from '@sqlpm/types-ts';

describe('databaseSystemVerify', () => {
  it(`should return true when the value provided
    is in the databasePlatform enum`, () => {
    expect(databaseSystemVerify('postgresql')).toEqual(true);
  });

  it(`should return false when the value provided
    is in the databasePlatform enum`, () => {
    expect(databaseSystemVerify('not')).toEqual(false);
  });
});
