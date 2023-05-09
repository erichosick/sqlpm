import commander from 'commander';
import {
  join,
} from 'node:path';

import {
  loadNodePackage,
} from '@sqlpm/node-package-ts';
import t from './i18';

// import generatePackageCommand from './command-generate-package';
// import actionGenerateSettings from './command-generate-settings';

export default async function commanderSqlpm():Promise<void> {
  const pkg = await loadNodePackage(join(__dirname, '..', 'package.json'));

  if (pkg === undefined) {
    throw Error(t('command.errors.missingPackage'));
  }

  // "command": {
  //   "name": "sqlpm",
  //   "description": "A package manager and migration tool for SQL.",
  //   "help": "\n\n  Example calls:\n  \n  $ sqlpm generate-package <json>\n",
  //   "errors": {
  //     "missingPackage": "Missing package.json in sqlpm project"
  //   }

  const program: commander.Command = new commander.Command();
  program
    .name(t('command.name'))
    .description(t('command.description'))
    .version(pkg?.content.version)
    .addHelpText('after', t('command.help'));
  // generatePackageCommand(program);
  // actionGenerateSettings(program);
  // program.exitOverride();
  program.parse(process.argv); // Override the default exit behavior;
}

// program
// .version(pkg?.content.version)
// .addHelpText('after', t('command.help'))
// .exitOverride(); // Override the default exit behavior;
