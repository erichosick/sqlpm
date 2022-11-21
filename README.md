# sqlpm

A bare-bones `lerna` mono-repo project.

* Tech stack:
  * eslint
  * jest + jsdom + unit/integration testing
  * lerna (package-level versioning)
  * typescript
  * yarn
  * webpack

[![lerna](https://img.shields.io/badge/maintained%20with-lerna-cc00ff.svg)](https://lerna.js.org/)

## How To Use These Libraries

**README:** For consumers of node packages ([jest](https://jestjs.io/) and [ts-node](https://www.npmjs.com/package/ts-node) as examples), by default, a transformer will not be invoked on a typescript package in `node_modules`: though these same libraries will automatically transform your typescript packages if they are located in any other directory.

The intent of packages in this mono-repo is to use the packages as a typescript libraries: compiling them to Javascript occurring within your project on release (using [tsc](https://www.typescriptlang.org/docs/handbook/compiler-options.html) for example). To use these libraries during development, you will need to enable transforming within the `node_modules` directory.

### **Jest**

To enable [jest transforming typescript](https://jestjs.io/docs/configuration#transformignorepatterns-arraystring) for `@sqlpm` projects in jest, add to your `jest.config.ts` the `transformIgnorePatterns: ['/node_modules/(?!(@sqlpm)/)']`. Your final config file should looks something like this:

```typescript
import type {
  Config,
} from 'jest';

const config: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  transformIgnorePatterns: ['/node_modules/(?!(@sqlpm)/)'],
};

export default config;
```

### **ts-node**

See [ts-node transpilation options](https://github.com/TypeStrong/ts-node#transpilation-options) for details.

```bash
# run ts-node with the -skipIgnore option
yarn ts-node --skipIgnore fails

# or using an environment variable
TS_NODE_SKIP_IGNORE=true yarn ts-node fail

```

## Development

Development requirements:

* Node + Yarn

```bash

# init all the projects
yarn

# continuously run tests
yarn test:unit:watch

# build any distributables and run unit tests
yarn test:unit

# build javascript library from typescript library
yarn build

# continuously build javascript library from typescript library
yarn build:watch

# publish all packages that have changed to npmjs.com
yarn publish:all
```

### Pushing Changes

```bash
# verify test run
yarn test:unit

# verify build works
yarn build

# make sure everything is commented, checked in and pushed into git
# TODO: Document code review process

# publish all packages that have changed
# you will need to have setup the account with npmjs.com
yarn publish:all

# enter the one-time password generated using 
# select correct version bump
```

### Adding a New Project

```bash
# Add a new project
yarn lerna:create {@name/new-package-name}  # @example yarn lerna:create @sqlpm/http-context

# Link it to other projects
yarn lerna add {@name/existing-module} --scope={@name/new-package-name}
```

### Linking To Another Project

```bash
yarn lerna add {@name/existing-module} --scope={@name/new-package-name}
# example
 yarn lerna add @sqlpm/universal-schema --scope=@sqlpm/iso-schema
```

### Database Libraries

* [node-postgres](https://github.com/brianc/node-postgres)
* [postgres.js](https://github.com/porsager/postgres)
