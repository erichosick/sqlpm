import {
  Connection,
} from './types';

export const connectionBuild = (
  connection: Partial<Connection> = {},
) => {
  // Environment variables override connection options.
  const { env } = process;
  const host = env.PGHOST || connection?.host;
  const port = Number(env.PGPORT) || connection?.port || 5432;
  const user = env.PGUSER || connection?.user;
  const password = env.PGPASSWORD || connection?.password;
  const dbname = env.PGDATABASE || connection?.dbname;
  const schema = env.PGSCHEMA || connection?.schema;

  if (!host || !user || !password || !dbname) {
    const missingOptions = [];
    if (!host) { missingOptions.push('host'); }
    if (!user) { missingOptions.push('user'); }
    if (!password) { missingOptions.push('password'); }
    if (!dbname) { missingOptions.push('database'); }

    // eslint-disable-next-line max-len
    const errorMessage = `Connection missing required options: ${missingOptions.join(', ')}. Required options can be set with environment variables or via the connection parameter`;
    throw Error(errorMessage);
  }

  return {
    host, port, user, password, dbname, schema,
  };
};

export const connectionParams = (
  connection: Partial<Connection> = {},
): string => (connection.schema ? `?search_path=${connection.schema}` : '');

export const connectionUri = (
  connection: Partial<Connection> = {},
): string => {
  const con = connection;
  return `postgresql://${con.user}:${con.password}@${con.host}:${con.port}/${con.dbname}${connectionParams(con)}`;
};

export const connectionUriNoPwd = (
  connection: Partial<Connection> = {},

):string => {
  const con = connection;
  return `postgresql://${con.user}:*****@${con.host}:${con.port}/${con.dbname}${connectionParams(con)}`;
};
