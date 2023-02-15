# `sqlpm`

**sqlpm** is the ultimate SQL Package Manager.

## Attention: Alpha Version

Please note that this project is still in its early stages of development and is considered an alpha version. However, if you have stumbled upon it, we would love to hear your feedback and thoughts. You can reach one of the authors by checking the package.json file.

## Introduction

sqlpm is a package manager specifically designed for SQL databases. Our goal is to support multiple database platforms, and currently, we support:

* PostgreSQL

## How it Works

**sqlpm** leverages the power of the JavaScript community and its approach to package management. You can install **sqlpm** packages using popular JavaScript package managers such as npm, yarn, or pnpm. Once installed, you can apply the SQL scripts located in the package to your PostgreSQL database instance by using **sqlpm** (work in progress).

## Key Features of **sqlpm**

### SQL Definitions

With **sqlpm**, SQL scripts are stored within a JavaScript package. You can find the SQL scripts in the [schemas]<https://github.com/erichosick/sqlpm/tree/main/schemas)> folder of the **sqlpm** repository. (see [lib](https://github.com/erichosick/sqlpm/tree/main/schemas/postgresql/lib) for our first package).

### Testing with BDD/TDD

**sqlpm** supports testing using the jest testing framework, and the tests are written in SQL. You can run tests in a behavior-driven development (BDD) mode with the command yarn `test:postgresql:watch`.

### Versioning

**sqlpm** uses versioning and supports it through lerna. This allows you to keep track of changes and updates to your SQL scripts.

### Dependencies

**sqlpm** leverages the dependency features of JavaScript package managers. This means that you can create dependencies between different **sqlpm** projects. With this, you can manage and organize your SQL scripts in a more efficient manner.
