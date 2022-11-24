import {
  MessagingOptions,
} from '@sqlpm/types-ts';

import {
  PostgresError,
} from 'postgres';

import {
  connectionOpen,
} from './connection-open';

import {
  Connection,
  DatabaseMutateSignature,
} from './types';

/**
 * Creates a database using the connection information provided. A new
 * connection is opened to the database service and then closed.
 * * **@param databaseName** The name of the database we are creating.
 * * **@param connection** - Connection information to the database.
 * See {@link Connection}
 * * **@throws** - Errors if there was an issue with creating the database
 * such as invalid database name or invalid connection.
 * * * **@returns** - A promise that resolves to true if the database
 * was created and false if the database already existed.
 */
export const databaseCreate: DatabaseMutateSignature = async (
  databaseName: string,
  connection: Connection,
  options?: MessagingOptions,
): Promise<boolean> => {
  const sql = connectionOpen(connection);
  try {
    // see https://github.com/npgsql/npgsql/issues/2730 as to why we don't
    // use a parameterized query. Also this error if we try to run the
    // create using Postgresql's EXECUTE(...) gives the error
    // ERROR:  CREATE DATABASE cannot run inside a transaction block.
    // Trying to run this within a DO$$ BEGIN ...END$$ returns the error
    // ERROR:  CREATE DATABASE cannot be executed from a function

    await sql.unsafe(`CREATE DATABASE ${databaseName};`);
  } catch (err) {
    if (err instanceof PostgresError) {
      const error = err as PostgresError;
      if (error.message.includes('already exists')) {
        options?.sendMsg?.debug(`Unable to create database ${databaseName} because it already exists.`);

        // We want this call to be idempotent so just ignore the already
        return false;
      } // else we are going to re-throw the error
    } // else we are going to re-throw the error
    throw (err);
  } finally {
    await sql.end({ timeout: 1 });
  }

  options?.sendMsg?.debug(`Successfully created database ${databaseName}.`);
  return true;
};

export interface DatabaseDropOptions extends MessagingOptions {

  /**
   * When true, any active connections are dropped before the database is
   * dropped. When, false, the database will not drop if there are active
   * connections. Useful when the database includes extensions like pg_cron.
   * Default is false.
   */
   closeActiveConnections?: boolean;

}

export const databaseDrop: DatabaseMutateSignature = async (
  databaseName: string,
  connection: Connection,
  options?: DatabaseDropOptions,
): Promise<boolean> => {
  const closeActiveConnections = options?.closeActiveConnections
    ? options.closeActiveConnections : false;
  const sql = connectionOpen(connection);
  try {
    const activeConnections = await sql`
      SELECT application_name
      FROM pg_stat_activity
      WHERE datname=${databaseName};
    `;

    if (activeConnections.length > 0) {
      if (closeActiveConnections) {
        await sql`
        SELECT pg_terminate_backend(pid)
        FROM pg_stat_activity
        WHERE datname=${databaseName};
       `;
      } else {
        const connections = activeConnections.map((con) => con.application_name).join(',');
        throw new Error(`Can not drop database ${databaseName} because it has the following active connections: '${connections}'.`);
      }
    }

    await sql.unsafe(`
    
    -- NOTE: We may want to consider dropping connections instead of erroring
    -- as we've done above
    -- SELECT pg_terminate_backend(pid)
    -- FROM pg_stat_activity
    -- WHERE datname='${databaseName}';
    
    DROP DATABASE ${databaseName};
   `);
  } catch (err) {
    if (err instanceof PostgresError) {
      const error = err as PostgresError;
      if (error.message.includes('does not exist')) {
        options?.sendMsg?.debug(`Unable to drop database ${databaseName} (code ${error.code}) because it does not exist.`);
        return false;
        // We want this call to be idempotent so just ignore the already
      }
    } // else log and return false

    throw (err);
    // return false;
  } finally {
    await sql.end({ timeout: 1 });
  }
  options?.sendMsg?.debug(`Successfully dropped database ${databaseName}.`);
  return true;
};
