/**
 * Checks if a value is a valid member of an enumeration.
 *
 * @template T - The type of the enumeration.
 * @param {T} enumObj - The enumeration object.
 * @param {unknown} value - The value to check.
 * @returns {value is T[keyof T]} - A boolean indicating whether the value is a
 * valid member of the enumeration.
 *
 * @example
 * ```typescript
 * enum TestEnum {
 *   One = 'one',
 *   Two = 'two',
 *   Three = 'three',
 * }
 *
 * if (isValidEnumValue(TestEnum, TestEnum.One)) {
 *   // The value 'one' is a valid member of the TestEnum enum.
 *   // Do something...
 * } else {
 *   // The value 'one' is not a valid member of the TestEnum enum.
 *   // Do something else...
 * }
 * ```
 */
export function isValidEnumValue<
  T extends Record<string, string>
>(enumObj: T, value: any): value is T[keyof T] {
  return Object.values(enumObj).includes(value);
}

/**
 * Converts an enumeration to an array of strings.
 * @template T - The type of the enumeration.
 * @param {T} enumObj - The enumeration object.
 * @returns {string} - A comma separated string of the enumeration values.
 * @example
 * ```typescript
 * enum TestEnum {
 *  One = 'one',
 *  Two = 'two',
 *  Three = 'three',
 * }
 * const testEnumArray = enumToStringArray(TestEnum);
 * // testEnumArray = 'one,two,three'
 * ```
 * @see {@link isValidEnumValue}
 */

export function enumToString<T extends Record<string, string>>(
  enumObj: T,
): string {
  return Object.values(enumObj).join(',');
}
