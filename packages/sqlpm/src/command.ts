import commanderSqlpm from './commander-sqlpm';

const command = async () => {
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

export default command;