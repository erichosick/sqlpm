// Unit tests only

import type {
  Config,
} from 'jest';

const unitTestConfig: Config = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: [
    '**/*.unit.spec.ts',
    // Ignoring integration tests. Called out explicitly because anything
    // matched in testMatch is automatically ignored by the test coverage.
    '!**/*.integration.spec.ts',
  ],
  collectCoverageFrom: [
    './packages/**/src/*.ts',
  ],
};

export default unitTestConfig;
