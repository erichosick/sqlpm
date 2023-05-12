import { Command } from 'commander';

import {
  parseSchemaProjectInit,
  schemaProjectInit,
} from '@sqlpm/package-generator-ts';

import generatePackageCommand,
{
  actionGeneratePackage,
} from '../src/command-generate-package';

import * as common from '../src/locales/en/common.json';

const packageGenerator = {
  schemaProjectInit: jest.fn(),
};

// eslint-disable-next-line no-import-assign, @typescript-eslint/no-unused-vars
(schemaProjectInit as any) = packageGenerator.schemaProjectInit;

describe('generatePackageCommand', () => {
  describe('command and help', () => {
    let program: Command;
    let commandFound: Command | undefined;

    beforeEach(() => {
      program = new Command();
      generatePackageCommand(program);
      commandFound = program.commands.find(
        (cmd) => cmd.name() === 'generate-package',
      );
    });

    it('should define a subcommand called "generate-package"', () => {
      expect(
        commandFound?.name(),
        'it should have a command named generate-package',
      ).toBe('generate-package');
    });

    it('should set the name and description of the subcommand', () => {
      expect(
        commandFound?.description(),
        'it should set the description',
      ).toBe(common.generatePackage.description);

      // eslint-disable-next-line no-underscore-dangle
      const cmdArgs = (commandFound as any)._args;
      expect(
        cmdArgs,
        'it should have arguments',
      ).toHaveLength(1);

      expect(
        cmdArgs[0].name(),
        'it should have an argument named "json"',
      ).toBe('json');

      expect(
        cmdArgs[0].description,
        'it should have the correct description for the argument',
      )
        .toBe(common.generatePackage.argument);
    });

    it('should add help text to the generate package subcommand', () => {
      const helpInformation = commandFound?.helpInformation();

      expect(helpInformation)
        .toContain(`Usage:  generate-package [options] <json>\n`);
      expect(helpInformation)
        .toContain(`Generates a new database schema package\n`);
      expect(helpInformation)
        .toContain(`A JSON object containing the configuration for generating the\n`);
      expect(helpInformation)
        .toContain(`package, including packageName, databaseSystem, description,\n`);
      expect(helpInformation)
        .toContain(`author, email, purposes, and actions.\n`);
      expect(helpInformation)
        .toContain(`-h, --help`);
      expect(helpInformation)
        .toContain(`display help for command`);
    });
  });

  describe('calls action', () => {
    let consoleLogSpy: jest.SpyInstance;

    beforeEach(() => {
      // Spy on console.log to capture the calls
      consoleLogSpy = jest.spyOn(console, 'log').mockImplementation();
    });

    afterEach(() => {
      // Clear the calls and restore the original console.log after each test
      consoleLogSpy.mockRestore();
      jest.clearAllMocks();
    });

    it('should call schemaProjectInit with correct arguments', async () => {
      const input = {
        packageName: 'testPackage',
        databaseSystem: 'postgresql',
        description: 'testDescription',
        author: 'testAuthor',
        email: 'testEmail',
        purposes: [
          'readwrite',
        ],
        actions: [
          'run',
          'test',
          'reset',
        ],
        workspace: 'testWorkspace',
      };

      await actionGeneratePackage(JSON.stringify(input));

      expect(
        packageGenerator.schemaProjectInit,
      ).toHaveBeenCalledWith(
        input.packageName,
        input.databaseSystem,
        input.description,
        input.author,
        input.email,
        input.purposes,
        input.actions,
        input.workspace,
      );

      expect(
        consoleLogSpy,
        'it should have generated helpful output for the user',
      ).toHaveBeenCalledTimes(2);

      expect(
        consoleLogSpy,
        'it should have used the generatePackage.messages.generating i8n',
      ).toHaveBeenNthCalledWith(1, common.generatePackage.messages.generating);

      expect(
        consoleLogSpy,
        'it should have used the generatePackage.messages.generating i8n',
      ).toHaveBeenNthCalledWith(
        2,
        parseSchemaProjectInit(JSON.stringify(input)),
      );
    });
  });
});
