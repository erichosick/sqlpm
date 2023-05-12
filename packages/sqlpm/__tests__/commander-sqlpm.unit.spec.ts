import { Command } from 'commander';
import { commanderBuildSqlpm } from '../src/commander-sqlpm';

describe('commanderBuildSqlpm', () => {
  test('should build the sqlpm commander program', async () => {
    const program: Command = await commanderBuildSqlpm();
    expect(program.helpInformation())
      .toContain(`Usage: sqlpm [options] [command]\n`);
    expect(program.helpInformation())
      .toContain('A package manager and migration tool for SQL.\n');
    expect(program.helpInformation())
      .toContain('Options:\n');
    expect(program.helpInformation())
      .toContain('-V, --version');
    expect(program.helpInformation())
      .toContain('-h, --help');
    expect(program.helpInformation())
      .toContain('Commands:\n');
    expect(program.helpInformation())
      .toContain('help [command]');
    expect(program.helpInformation())
      .toContain('display help for command');
    expect(program.helpInformation())
      .toContain('generate-package <json>');
    expect(program.helpInformation())
      .toContain('Generates a new database schema package\n');
    // expect(program.helpInformation())
    //   .toContain('generate-settings [options]');
    // expect(program.helpInformation())
    //   .toContain('Generates a settings file for sqlpm\n');
  });
});
