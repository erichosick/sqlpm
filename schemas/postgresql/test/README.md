# **test-postgresql**

Contains resources for testing. This [Sqlpm](https://github.com/erichosick/sqlpm) package is used by other Sqlpm for running tests within Sql.

## Introduction

This package contains re-usable [Postgresql](https://www.postgresql.org/) sql. The package is installed using a traditional javascript package manager such as [npm](https://www.npmjs.com/), [yarn](https://yarnpkg.com/) or [pnpm](https://pnpm.io/). Applying the sql located in the package to a Postgresql database instance is done using [Sql Package Manager](https://github.com/erichosick/sqlpm).

This package has:

* **definitions** - Sql is stored within the package.
* **Testing, BDD/TDD** - Testing is done using the [jest](https://jestjs.io/) testing framework but the tests are written in Sql. True behavior driven development is supported via `yarn test:postgresql:watch`.
* **versioned** - Versioning is used and supported via [lerna](https://lerna.js.org/).
* **dependencies** - The dependency features of the javascript package manager are leveraged. [Sql Package Manager](https://github.com/erichosick/sqlpm) projects can depend on other projects.

## Usage

// TODO

## Generated

This package was generated using [@sqlpm/package-generator-ts](https://www.npmjs.com/package/@sqlpm/package-generator-ts).
