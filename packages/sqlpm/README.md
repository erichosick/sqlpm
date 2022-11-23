# `sqlpm`

**sqlpm** is a SQL Package manager.

WARNING: Very early alpha. We are currently low key on the work going on with this project. However, if you happen upon it, please contact one of the authors (see package.json). We would be very interested in hearing your thoughts.

## Introduction

SQL Package manager is a package manager for sql. We plan on supporting different database platforms but currently only support:

* Postgresql

## How Does It Work

We leverage the existing javascript community and their approach to package management. Sqlpm packages are installed using a traditional javascript package manager such as [npm](https://www.npmjs.com/), [yarn](https://yarnpkg.com/) or [pnpm](https://pnpm.io/). Applying the sql located in the package to a Postgresql database instance can be done by using Sql Package Manager (Work in Progress).

**Features**

* **definitions** - Sql is stored within a javascript package (see [lib](https://github.com/erichosick/sqlpm/tree/main/schemas/postgresql/lib) - our first managed sql).
* **Testing, BDD/TDD** - Testing is done using the [jest](https://jestjs.io/) testing framework but the tests are written in Sql. True behavior driven development is supported via `yarn test:postgresql:watch`.
* **versioned** - Versioning is used and supported via [lerna](https://lerna.js.org/).
* **dependencies** - The dependency features of the javascript package manager are leveraged. [Sql Package Manager](https://github.com/erichosick/sqlpm) projects can depend on other projects.
