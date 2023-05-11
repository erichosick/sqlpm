import commander, { CommanderError } from 'commander';
import {
  join,
} from 'node:path';

import {
  loadNodePackage,
} from '@sqlpm/node-package-ts';
import t from './i18';

import generatePackageCommand from './command-generate-package';
// import actionGenerateSettings from './command-generate-settings';

function errorColor(str: string) {
  // Add ANSI escape codes to display text in red.
  return `\x1b[31m${str}\x1b[0m`;
}

export const commanderBuildSqlpm = async (): Promise<commander.Command> => {
  const pkg = await loadNodePackage(join(__dirname, '..', 'package.json'));
  const version = pkg?.content.version || 'unknown';

  const program: commander.Command = new commander.Command();
  program
    .name(t('command.name'))
    .description(t('command.description'))
    .version(version)
    .addHelpText('after', t('command.help'))
    .configureOutput({
      // Even though this doesn't seem to do anything, adding the following
      // enables us to route stdout to null. If we don't add this, even though
      // we route stout to null, commander still writes out the console.
      writeOut: (str) => process.stdout.write(str),
      writeErr: (str) => process.stdout.write(str),
      // Highlight errors in color.
      outputError: (str: string, write) => write(errorColor(str))
    })
    ;
  generatePackageCommand(program);
  // actionGenerateSettings(program);

  program.exitOverride(); // Override the default exit behavior;
  return program;
}


const commanderSqlpm = async (): Promise<void> => {
  const program = await commanderBuildSqlpm();
  await program.parseAsync(process.argv)
    .catch((err) => {
      if (err instanceof CommanderError) {
        if (err.code !== 'commander.helpDisplayed'
          && err.code !== 'commander.help') {
          throw err;
        } // else do nothing as commander will have shown the help
      } else {
        throw err;
      }
    })
}

export default commanderSqlpm;

