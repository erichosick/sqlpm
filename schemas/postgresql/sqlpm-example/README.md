# **sqlpm-example-postgresql**

Used to test the sqlpm along with .

## Usage

## Generated

This package was generated using @sqlpm/project-generator-ts as follows:

```typescript
import {
  DatabasePlatform,
  DatabasePurpose,
} from '@sqlpm/types-ts';

import {
  schemaProjectInit,
} from '@sqlpm/package-generator-ts';

(async () => {
  await schemaProjectInit(
    'sqlpm-example',
    DatabasePlatform.Postgresql,

    'Used to test the sqlpm along with .',
    'Eric Hosick',
    'erichosick@gmail.com',
    [DatabasePurpose.Readwrite, DatabasePurpose.Readonly],
  );
})();

```
