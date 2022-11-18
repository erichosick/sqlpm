// Integration and Unit Tests

import type {
  Config,
} from 'jest';

const integrationTestConfig: Config = {
  preset: 'ts-jest',

  // Warning: fakeTimers requires the node environment. They don't work in
  // the jsdom environment.
  testEnvironment: 'node',
  testMatch: [
    '**/*.unit.spec.ts',
    '**/*.integration.spec.ts',
  ],
  collectCoverageFrom: [
    './packages/**/src/*.ts',
  ],

  // required by postgres library
  // see https://deltice.github.io/jest/docs/en/jest-object.html#jestusefaketimers
  fakeTimers: {
    enableGlobally: true,
  },
};

export default integrationTestConfig;
