import commanderSqlpm from './commander-sqlpm';

export default async function command() {
  await commanderSqlpm()
    .catch((err) => {
      // eslint-disable-next-line no-console
      console.log(err);
      process.exit(1);
    })
    .finally(() => {
      process.exit(0);
    });
}
