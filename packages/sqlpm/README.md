# `sqlpm`

`sqlpm` is a package manager for SQL.

## Alpha Version

Please note that this project is still in its early stages of development and is considered an alpha version.

If you have stumbled upon it, we would love to hear your feedback and thoughts. You can reach one of the authors by checking the `package.json` file.

## Introduction

`sqlpm` is a source code package manager for SQL. `sqlpm` gives SQL access to programming tools other languages have such as:

* [Semantic versioning](https://en.wikipedia.org/wiki/Software_versioning#Semantic_versioning)
* Behavior and test driven development
* Reusable installable sql packages
* Package dependency
* Support for multiple SQL flavors
* Works especially well with mono-repos

## How it Works

`sqlpm` leverages existing JavaScript development tools to manage SQL source-code:

* [yarn](https://yarnpkg.com/) ([npm](https://www.npmjs.com/), [pnpm](https://pnpm.js.org/), etc.) for package management
* [jest](https://jestjs.io/) ([Mocha]( https://mochajs.org/), [Karma](https://karma-runner.github.io/), etc.), for testing
* [Lerna](https://lerna.js.org/) ([Semantic Release](https://semantic-release.gitbook.io/), [Conventional Changelog](https://github.com/conventional-changelog/conventional-changelog), etc.) for semantic versioning
* [Lerna](https://lerna.js.org/) for mono-repo
* Sqlpm for package dependency

## Usage

TODO

## SQL Packages

Although not specific to `sqlpm`, we've have started to create some SQL packages ourselves located in the [schemas](https://github.com/erichosick/sqlpm/tree/main/schemas) folder of the `sqlpm` mono-repo. (see [persona](https://github.com/erichosick/sqlpm/tree/main/schemas/postgresql/persona) for an example `sqlpm` package).
