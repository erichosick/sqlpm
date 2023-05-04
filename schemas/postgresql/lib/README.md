# **lib-postgresql**

A library of reusable Postgresql domains.

## Introduction

This package contains re-usable [Postgresql](https://www.postgresql.org/) sql. The package is installed using a traditional javascript package manager such as [npm](https://www.npmjs.com/), [yarn](https://yarnpkg.com/) or [pnpm](https://pnpm.io/). Applying the sql located in the package to a Postgresql database instance can be done by using [Sql Package Manager](https://github.com/erichosick/sqlpm/tree/main/packages/sqlpm) or a migration tool of your choosing.

This package has:

* **definitions** - Sql is stored within the package.
* **Testing, BDD/TDD** - Testing is done using the [jest](https://jestjs.io/) testing framework but the tests are written in Sql. True behavior driven development is supported via `yarn test:postgresql:watch`.
* **versioned** - Versioning is used and supported via [lerna](https://lerna.js.org/).
* **dependencies** - The dependency features of the javascript package manager are leveraged. [Sql Package Manager](https://github.com/erichosick/sqlpm/tree/main/packages/sqlpm) projects can depend on other projects.

## Usage

### Domain Definitions

#### Keys

Domains for primary and foreign keys.

* **lib.key_uuid**
* **lib.key_uuid_nullable**
* **lib.key_str_36**
* **lib.key_str_64**
* **lib.key_str_128**
* **lib.key_symbol**
* **lib.key_bigint**
* **lib.key_int**
* **lib.key_smallint**
* **lib.key_slug_128**
* **lib.key_htag**
* **lib.key_lhtag**

#### Percentages

Domains for columns that are percentages.

* **lib.percent_7_1**
* **lib.percent_7_1_null**
* **lib.percent_7_2**
* **lib.percent_7_2_null**
* **lib.percent_7_3**
* **lib.percent_7_3_null**
* **lib.percent_7_4**
* **lib.percent_7_4_null**

#### Currencies

Domains for scalar part of currency. Currency type is defined in the [iso schema](https://github.com/erichosick/sqlpm/tree/main/schemas/postgresql/iso).

* **lib.currency_0**
* **lib.currency_0_null**
* **lib.currency_2**
* **lib.currency_2_null**
* **lib.currency_4**
* **lib.currency_4_null**

#### PostgreSQL Domains

* **lib.sql_identifier** - Valid, but more strict, PostgreSql identifiers and key words (tables, columns, schema).
* **lib.sql_identifier_lower** - Valid, but more strict, lower case PostgreSql identifiers and key words (tables, columns, schema).

#### Internet Related Domains

* **lib.url** - A url (universal resource locator).
* **lib.email** - An email address.
* **lib.color_hex** - An HTML hex color of format #rrggbb.

#### Human Readable Domains

* **lib.name** - The name of an entity such as a person, organization, or persona.
* **lib.label** - A human readable value often used in, drop down list box, as a check box label, radio label, etc.
* **lib.label_short** - A human readable value used in situations where there isn not a lot of screen space in the ui.
* **lib.title** - A human readable value often used in, drop down list box, as a check box label, radio label, etc.
* **lib.description** - A human readable value providing detailed information about an entry used for things like tool-tips, documentation, explanations, etc.

#### Frequency Domains

* **lib.frequency_8_4** - A frequency (say average number of times an event occurred each second, etc.) with 4 digits of precision and maximum of 99,999,999.9999.
* **lib.frequency_8_8** - A frequency (say average number of times an event occurred each second, etc.) with 8 digits of precision and maximum of 99,999,999.99999999.

## Code Generation

This package was generated from the root of the mono-repo as follows:

```bash
yarn sqlpm generate '{"packageName": "lib", "databaseSystem": "postgresql", "description": "A library of reusable Postgresql domains.", "author": "...", "email": "...", "purposes": ["readwrite"], "actions": ["run", "test", "reset"]}'

# Add sql testing dependency
yarn lerna add @sqlpm/sqlpm-lib-ts --scope=@sqlpm/lib-postgresql

# Add the test schema dependency
yarn lerna add @sqlpm/test-postgresql --scope=@sqlpm/lib-postgresql
```

## Development

See the README.md at the root of the mono-repo to learn how to add new domains to this package.
