# **sqlpm-example-postgresql**

Used to test the sqlpm along with .

## Usage

## Generated

This package was generated [@sqlpm/package-generator-ts](https://www.npmjs.com/package/@sqlpm/package-generator-ts) as follows:

```typescript
import {
  DatabaseSystem,
  DatabaseAccessMode,
} from '@sqlpm/types-ts';

import {
  schemaProjectInit,
} from '@sqlpm/package-generator-ts';

(async () => {
  await schemaProjectInit(
    'sqlpm-example',
    DatabaseSystem.Postgresql,

    'Used to test the sqlpm along with .',
    'Eric Hosick',
    'erichosick@gmail.com',
    [DatabaseAccessMode.ReadWrite, DatabaseAccessMode.ReadOnly],
  );
})();

```
