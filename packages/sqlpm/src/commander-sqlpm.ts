import commander from 'commander';
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
export default async function commanderSqlpm(): Promise<void> {
  const pkg = await loadNodePackage(join(__dirname, '..', 'package.json'));

  if (pkg === undefined) {
    throw Error(t('command.errors.missingPackage'));
  }

  const program: commander.Command = new commander.Command();
  program
    .name(t('command.name'))
    .description(t('command.description'))
    .version(pkg?.content.version)
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
  // program.exitOverride();
  program.parse(process.argv); // Override the default exit behavior;
}
