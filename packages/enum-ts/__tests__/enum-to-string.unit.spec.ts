import {
  enumToString,
} from '../src/index';

describe('enumToString', () => {
  it('should convert an enumeration to a comma separated string', () => {
    enum StringEnum {
      OneA = 'one',
      TwoA = 'two',
      ThreeA = 'three',
    }

    const result = enumToString(StringEnum);
    expect(
      result,
      'it should return the string values of the enum',
    ).toEqual('one,two,three');
  });

  it('should return an empty string if the enumeration is empty', () => {
    enum EmptyEnum {}

    const result = enumToString(EmptyEnum);
    expect(
      result,
      'it should return an empty string because the enum is empty',
    ).toEqual('');
  });
});
