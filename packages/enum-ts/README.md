# `@sqlpm/enum-ts`

A utility project that has helper functions for verifying and displaying
typescript enums.

## Usage

### isValidEnumValue

Checks if a value is a valid member of an enumeration.

@template T - The type of the enumeration.
@param {T} enumObj - The enumeration object.
@param {unknown} value - The value to check.
@returns {value is T[keyof T]} - A boolean indicating whether the value is a
valid member of the enumeration.

@example

```typescript
enum TestEnum {
  One = 'one',
  Two = 'two',
  Three = 'three',
}

if (isValidEnumValue(TestEnum, TestEnum.One)) {
  // The value 'one' is a valid member of the TestEnum enum.
  // Do something...
} else {
  // The value 'one' is not a valid member of the TestEnum enum.
  // Do something else...
}
```

### enumToString

Converts an enumeration to an array of strings.
@template T - The type of the enumeration.
@param {T} enumObj - The enumeration object.
@returns {string} - A comma separated string of the enumeration values.
@example

```typescript
enum TestEnum {
 One = 'one',
 Two = 'two',
 Three = 'three',
}
const testEnumArray = enumToStringArray(TestEnum);
// testEnumArray = 'one,two,three'
```
