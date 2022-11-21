import postgres from 'postgres';

export const sqlApplyFromFile = async (
  path: string,
  sql: postgres.Sql<{}>,
): Promise<void> => {
  // TODO: A lot of work here to do.
  // console.log(`Running file '${path}' on the database server`);
  // await this.sql.begin(async () => {
  await sql.file(path)
    .catch((err: unknown) => {
      // if (err instanceof PostgresError) {
      //   this.logPostgreSqlError(fileName, err);
      // }
      // rethrow the error so we don't try to run anymore files.
      throw err;
    });
  // }).catch((err: unknown) => {
  //   throw err;
  // });
};
