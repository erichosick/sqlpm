import {
  resolve,
  join,
} from 'node:path';

import {
  PathLike,
} from 'fs';

import {
  mkdir,
  rmdir,
  readdir,
} from 'fs/promises';

import {
  ReadOptions,
} from './types';

/**
 * Given an absolute path, recursively creates the directory in that path.
 * * **@param path** The absolute path containing the directories to create.
 * * **@returns** A promise that when it resolves to true means the directory
 * was successfully created.
 */
export const dirCreate = async (
  path: string,
): Promise<boolean> => {
  await mkdir(path, {
    recursive: true,
  });
  return true;
};

/**
 * Given an absolute path, removes an empty directory.
 * @param path The absolute path to the directory
 */
export const dirRemove = async (
  path: string,
): Promise<boolean> => {
  let removed = false;
  try {
    await rmdir(path);
    removed = true;
  } catch (err) {
    const error = err as Error;
    if (error.message.includes('ENOENT')) {
      return false;
    } // else {} throw the exception
    throw (err);
  }

  return removed;
};

/**
 * TODO: Documentation
 * @param rootDir
 * @param subDirectories
 * @returns
 */
export const dirsCreate = async (
  rootDir: string,
  subDirectories: string[],
): Promise<boolean> => {
  const root = resolve(rootDir);

  const createDirs = subDirectories.map((subDir) => dirCreate(join(root, subDir)));

  await Promise.all(createDirs);
  return true;
};

/**
 * Given an absolute or relative path, asynchronously returns all of the file
 * names in a directory.
 *
 * * **@param path** - The absolute or relative path to the file.
 *
 * * **@param [options]**
 *   * **[options.required=true]** - When `true` or `undefined`, when the
 *   directory is not found an exception is thrown. When `false`, no exception
 *   is thrown and `undefined` is returned.
 *
 * * **@throws** - Errors if the directory is not found when
 *   `options.required` is `true`.
 * * **@returns** - An array of file names.
 *
 * **@example**
 * Get the file names of all files in a given directory.
 *
 * ```typescript
 * import {
 *   dirRead
 * } from '@sqlpm/file-ts';
 *
 * (async () => {
 *   const files: string[] | undefined = await dirRead(__dirname);
 *   expect(files?.length).toBeGreaterThan(0);
 * })();
 * ```
*/
export const dirRead = async (
  path: PathLike,
  options?: ReadOptions,
): Promise<string[] | undefined> => {
  try {
    return await readdir(path);
  } catch (err) {
    if (undefined === options?.required || options.required) {
      throw (err);
    }
  }
  return undefined;
};
