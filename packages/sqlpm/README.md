# `sqlpm`

SQL Package Manager

## Examples

```bash

yarn sqlpm generate '{"packageName": "lib-domain", "platform": "postgresql", "description": "A library of reusable Postgresql domains placed in the lib schema", "author": "Eric Hosick", "email": "erichosick@gmail.com", "purposes": ["readwrite"], "actions": ["run", "test", "reset"]}'
yarn lerna add @sqlpm/sqlpm-lib-ts --scope=@sqlpm/domain-lib-postgresql


yarn sqlpm generate '{"packageName": "universal", "platform": "postgresql", "description": "", "author": "Eric Hosick", "email": "erichosick@gmail.com", "purposes": ["readwrite"], "actions": ["prerun", "run", "test", "reset"]}'

yarn lerna add @sqlpm/sqlpm-lib-ts --scope=@sqlpm/universal-postgresql
yarn lerna add @sqlpm/test-postgresql --scope=@sqlpm/universal-postgresql

yarn sqlpm generate '{"packageName": "test", "platform": "postgresql", "description": "Contains resources that can be used for testing.", "author": "Eric Hosick", "email": "erichosick@gmail.com", "purposes": ["readwrite"], "actions": ["run", "test", "reset"]}'

yarn lerna add @sqlpm/sqlpm-lib-ts --scope=@sqlpm/test-postgresql

```
