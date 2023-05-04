import {
  isValidEnumValue,
} from '../src/index';

enum TestEnum {
  One = 'one',
  Two = 'two',
  Three = 'three',
}

describe('isValidEnumValue', () => {
  it('should return true for a valid enum value', () => {
    const result = isValidEnumValue(TestEnum, TestEnum.One);
    expect(result, 'value should be a valid TestEnum value').toBe(true);
  });

  it('should return false for an invalid enum value', () => {
    expect(isValidEnumValue(TestEnum, 'four'), 'value should not be a valid TestEnum value').toBe(false);
  });

  it('should return true for a valid enum value using a type guard', () => {
    if (isValidEnumValue(TestEnum, 'two')) {
      expect('two', 'value should be of type TestEnum').toBe('two');
    } else {
      expect(true, 'Type guard should have returned true for a valid value.').toBe(false);
    }
  });

  it('should return false for an invalid enum value using a type guard', () => {
    const value: string = 'four';
    if (isValidEnumValue(TestEnum, value)) {
      expect(true, 'value should not be a valid TestEnum value').toBe(false);
    } else {
      expect(value, 'value should not be of type TestEnum').not.toBe(TestEnum.Three);
    }
  });
});
