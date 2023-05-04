# **logging-postgresql**

contains features around logging, notifications, and notices.

## Introduction

This package contains re-usable [Postgresql](https://www.postgresql.org/) sql ddl. The package is installed using a traditional node package manager such as [npm](https://www.npmjs.com/), [yarn](https://yarnpkg.com/) or [pnpm](https://pnpm.io/). Applying the sql located in the package to a Postgresql database instance can be done by using [Sql Package Manager](https://github.com/erichosick/sqlpm/tree/main/packages/sqlpm) or a migration tool of your choosing.

This package has:

* **definitions** - Sql is stored within the package.
* **Testing, BDD/TDD** - Testing is done using the [jest](https://jestjs.io/) testing framework but the tests are written in Sql. True behavior driven development is supported via `yarn test:postgresql:watch`.
* **versioned** - Versioning is used and supported via [lerna](https://lerna.js.org/).
* **dependencies** - The dependency features of the javascript package manager are leveraged. [Sql Package Manager](https://github.com/erichosick/sqlpm/tree/main/packages/sqlpm) projects can depend on other projects.

## Usage

// TODO

## Generated

This package was generated form the root of this repository as follows:

```bash
yarn sqlpm generate '{"packageName": "logging", "databaseSystem": "postgresql", "description": "contains features around logging, notifications, and notices.", "author": "...", "email": "...", "purposes": ["readwrite"], "actions": ["run", "test", "reset"]}'

yarn lerna add @sqlpm/sqlpm-lib-ts --scope=@sqlpm/logging-postgresql

# Add the universal schema dependency
yarn lerna add @sqlpm/universal-postgresql --scope=@sqlpm/logging-postgresql

# Add the tag schema dependency
yarn lerna add @sqlpm/tag-postgresql --scope=@sqlpm/logging-postgresql

# Add the tag schema dependency
yarn lerna add @sqlpm/persona-postgresql --scope=@sqlpm/logging-postgresql
```
