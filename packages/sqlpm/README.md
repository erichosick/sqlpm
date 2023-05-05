# `sqlpm`

`sqlpm` is a package manager for SQL, designed to help developers manage SQL code similarly to how other programming languages are managed. It offers a command-line interface to create schema projects, manage database configurations, and run SQL scripts against database instances, making it easier to maintain and update your SQL codebase.

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

## Introduction

`sqlpm` is a source code package manager for SQL that empowers SQL with the programming tools and features commonly found in other languages. With `sqlpm`, you can leverage the following capabilities in your SQL projects:

* [Semantic versioning](https://en.wikipedia.org/wiki/Software_versioning#Semantic_versioning): Manage and track the versions of your SQL packages with a standardized and meaningful numbering scheme.
* Package Dependency: Manage the dependencies between SQL packages, ensuring that the correct versions and dependencies are installed and used in your projects.
* Reusable Installable SQL Packages: Create and distribute reusable SQL packages that can be easily installed and integrated into other projects.
* Behavior and Test-Driven Development.
* Support for Multiple SQL Flavors.
* Works Especially Well with Mono-Repos.
* Continuous Integration and Continuous Deployment (CI/CD) Support: Integrate your SQL code with modern CI/CD pipelines to automate testing, build, and deployment processes, ensuring consistent and reliable updates to your databases.
* Environment Management: Easily manage different database environments, such as development, staging, and production, using sqlpm's configuration capabilities, simplifying the deployment and migration process.
* Modular and Structured SQL Code: Organize your SQL code into modular units and directories, making it easier to understand, maintain, and collaborate on complex database projects.
* Code Refactoring and Optimization: Utilize sqlpm to efficiently refactor and optimize your SQL code, improving query performance and reducing technical debt in your projects.
* Collaborative Development: Facilitate team collaboration on SQL projects with standardized tools and conventions, making it easier for developers to work together and contribute to the codebase.

## Features

## Generate Project

The "Generate Project" feature in `sqlpm` allows you to quickly set up a new SQL project with the necessary directory structure and files. This feature streamlines the process of starting a new SQL project and ensures that your project follows best practices for organization and structure.

#### Usage

To generate a new project, run the following command:

```bash
sqlpm generate-project ${project-name}
```

## How it Works

`sqlpm` leverages existing JavaScript development tools to manage SQL source-code:

* [yarn](https://yarnpkg.com/) ([npm](https://www.npmjs.com/), [pnpm](https://pnpm.js.org/), etc.) for package management
* [jest](https://jestjs.io/) ([Mocha]( https://mochajs.org/), [Karma](https://karma-runner.github.io/), etc.), for testing
* [Lerna](https://lerna.js.org/) ([Semantic Release](https://semantic-release.gitbook.io/), [Conventional Changelog](https://github.com/conventional-changelog/conventional-changelog), etc.) for semantic versioning
* [Lerna](https://lerna.js.org/) for mono-repo
* Sqlpm for package dependency

## SQL Packages

Although not specific to `sqlpm`, we've have started to create some SQL packages ourselves located in the [schemas](https://github.com/erichosick/sqlpm/tree/main/schemas) folder of the `sqlpm` mono-repo. (see [persona](https://github.com/erichosick/sqlpm/tree/main/schemas/postgresql/persona) for an example `sqlpm` package).
