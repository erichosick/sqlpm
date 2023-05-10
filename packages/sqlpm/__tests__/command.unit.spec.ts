import { mocked } from 'jest-mock';
import { loadNodePackage } from '@sqlpm/node-package-ts';
import command from '../src/command';
import * as common from '../src/locales/en/common.json';

import silenceStdout from './silence-stdout';

jest.mock('@sqlpm/node-package-ts');

const mockedLoadNodePackage = mocked(loadNodePackage);

describe('commander-sqlpm', () => {
  let restoreStdout: () => void;

  beforeEach(() => {
    restoreStdout = silenceStdout();
    // Reroute Commander's output to the null stream
    jest.resetAllMocks();
  });

  afterEach(() => {
    restoreStdout();
    // Restore the original stdout and stderr streams after each test
    jest.clearAllMocks();
  });

  test('should execute without error', async () => {
    const processExitSpy = jest.spyOn(process, 'exit').mockImplementation();

    mockedLoadNodePackage.mockResolvedValue({
      sourcePath: '/path/to/package.json',
      content: {
        name: 'sample-package',
        version: '1.0.0',
      },
    });

    await command();

    expect(mockedLoadNodePackage).toHaveBeenCalled();

    expect(processExitSpy).toHaveBeenCalledWith(0);

    processExitSpy.mockRestore();
  });

  test('should throw error if package is undefined', async () => {
    const consoleSpy = jest.spyOn(console, 'log').mockImplementation();
    const processExitSpy = jest.spyOn(process, 'exit').mockImplementation();

    mockedLoadNodePackage.mockResolvedValue(undefined);

    await command();

    expect(mockedLoadNodePackage).toHaveBeenCalled();
    // expect(mockedT).toHaveBeenCalled();

    expect(consoleSpy).toHaveBeenCalledWith(
      new Error(common.command.errors.missingPackage),
    );
    expect(processExitSpy).toHaveBeenCalledWith(1);

    consoleSpy.mockRestore();
    processExitSpy.mockRestore();
  });
});
