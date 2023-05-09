/* eslint-disable no-console */
import commander from 'commander';
import {
  parseSchemaProjectInit,
  schemaProjectInit,
} from '@sqlpm/package-generator-ts';
import t from './i18';

export async function actionGeneratePackage(json: string) {
  const input = parseSchemaProjectInit(json);

  console.log(t('generatePackage.messages.generating'));
  console.log(input);
  await schemaProjectInit(
    input.packageName,
    input.databaseSystem,
    input.description,
    input.author,
    input.email,
    input.purposes,
    input.actions,
    input.workspace,
  );
}

export default function generatePackageCommand(
  program: commander.Command,
) {
  program
    .command(t('generatePackage.command'))
    .action(actionGeneratePackage)
    .description(t('generatePackage.description'))
    .argument('<json>', t('generatePackage.argument'))
    .addHelpText('after', t('generatePackage.help'));
}
