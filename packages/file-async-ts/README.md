# **@sqlpm/file-async-ts**

`@sqlpm/file-async-ts` is a typescript library applying the [facade pattern](https://en.wikipedia.org/wiki/Facade_pattern) to asynchronous file access.

**README:** See [How to Use This Library](https://github.com/erichosick/sqlpm#how-to-use-these-libraries) to learn how to enable transpilation for local development or tools like [jest](https://jestjs.io/) or [ts-node](https://www.npmjs.com/package/ts-node) won't work.

## Features

* 100% typescript.
* 100% asynchronous library.
* functions
  * **fileContentDetailStr** - Returns a file path and file content as a string.
  * **fileExists** - Check if a file exists.
  * **readFile** - Read from a file returning a Buffer.
  * **readFileString** -Read from a file returning a string.
  * **dirRead** Returns a list of files from a directory.
  * **parentPaths** - Given a path, returns an array of all parent paths.

## Usage

## **fileContentDetailStr** - Get a Files Path and Associated Contents

Reads the contents of a file, converting the contents to a string, and
returning the contents of the file associated with the path of the file.

* **@param path** -  The absolute or relative path to the file.
* **@param [options]**
  * **[options.required=true]** - When `true` or `undefined`, when the file is
  not found an exception is thrown. When `false`, no exception is thrown and
  `undefined` is returned.
* **@throws** - An error is thrown if the file is not found and
`options.required` was set to true.
* **returns** - The contents of the file along with the associated path.
Undefined may be returned if the `options.required` was set to false.

 **@example**
Return file meta data and content details.

```typescript
import { join } from 'node:path';
import { fileContentDetailStr } from '@sqlpm/file-async-ts';

(async () => {
  const dir = join(__dirname, 'test-files', 'info.txt');
  const contentDetail = await fileContentDetailStr(dir);
  expect(contentDetail?.content)
    .toEqual('A file with content.');
  expect(contentDetail?.filePath)
    .toMatch(/[\S]*\/__tests__\/test-files\/info.txt$/);
})();
```

## **fileExists** - Asynchronously Checking if a File Exists

Asynchronously check if a file exists.

* **@param path** -  The absolute or relative path to the file.
* **@returns** - True when the file exists and false otherwise.

**@example**
Checks if a file exists.

```typescript
import { join } from 'node:path';
import { fileExists } from '@sqlpm/file-async-ts';

(async () => {
  const dir = join(__dirname, 'file-exists.unit.spec.ts');
  const exists: boolean = await fileExists(dir);
  expect(exists).toEqual(true);
})();
```

## **readFile** - Asynchronously Read All Contents of a File

Given an absolute or relative path, asynchronously reads all the contents of
the file into a buffer.

**@remarks**
Intended use is only for relatively small files. For large files
use streams.

* **@param path** - The absolute or relative path to the file.

* **@param [options]**
  * **[options.required=true]** - When `true` or `undefined`, when the file is
  not found an exception is thrown. When `false`, no exception is thrown and
  `undefined` is returned.

* **@throws** - Errors if the file is not found when `options.required` is `true`.
* **@returns** - Contents of the file as a buffer if the file existed,
  `undefined` when required is `false` and the file was not found.

**@example**
Reads the contents of a file into a `Buffer`.

```typescript
import { join } from 'node:path';
import { readFile } from '@sqlpm/file-async-ts';

(async () => {
  const dir = join(__dirname, 'index.ts');
  const content: Buffer | undefined = await readFile(dir);
  console.info(content);
})();
```

## **readFileString** - Asynchronously Read All Contents of a File Into A String

Given an absolute or relative path, asynchronously reads all the contents of
the file into a string.

**@remarks**
Intended use is only for relatively small files. For large files
use streams.

* **@param path** - The absolute or relative path to the file.

* **@param [options]**
  * **[options.required=true]** - When `true` or `undefined`, when the file is
  not found an exception is thrown. When `false`, no exception is thrown and
  `undefined` is returned.

* **@throws** - Errors if the file is not found when `options.required` is `true`.
* **@returns** - Contents of the file as a string if the file existed,
  `undefined` when required is `false` and the file was not found.

**@example**
Reads the contents of a file into a `string`.

```typescript
import { join } from 'node:path';
import { readFileString } from '@sqlpm/file-async-ts';

(async () => {
  const dir = join(__dirname, 'read-file.unit.spec.ts');
  const content: string | undefined = await readFileString(dir);
  expect(content).toBeDefined();
})();
```

## **dirRead** - Return a List of Files Names From a Directory

Given an absolute or relative path, asynchronously returns all of the file
names in a directory.

* **@param path** - The absolute or relative path to the file.
* **@param [options]**
  * **[options.required=true]** - When `true` or `undefined`, when the
  directory is not found an exception is thrown. When `false`, no exception
  is thrown and `undefined` is returned.
* **@throws** - Errors if the directory is not found when
  `options.required` is `true`.
* **@returns** - An array of file names.
**@example**
Get the file names of all files in a given directory.

```typescript
import {
  dirRead
} from '@sqlpm/file-ts';
(async () => {
  const files: string[] | undefined = await dirRead(__dirname);
  expect(files?.length).toBeGreaterThan(0);
})();
```

## **parentPaths** - Getting All Paths of a Child Path

Given an absolute path, `parentPaths` returns an array containing all
possible parent paths, including the root path ordered by the child path
to the root path.

**@remarks**
The child path is normalized before all possible parent paths are
generated. For example, `/cat/../and/mouse` becomes `/and/mouse`.

* **@param childPath** - The absolute path used to generate all possible
 parent paths.
* **@param [options]**
  * **[options.depth]** - The number of parent paths to return, starting
    from the child path. When undefined, all paths are returned up to and
    including the root path.
* **@throws** - An error is thrown if `childPath` is not an absolute path.
* **@returns** - An array containing all possible parent paths
including the root path ordered by the child path first.

**@example**
Return all parent paths of a child path.

```typescript
import {
  parentPaths,
} from '@sqlpm/file-async-ts';

const result: string[] = parentPaths('/cat/mouse');
expect(result).toEqual([
  '/cat/mouse',
  '/cat',
  '/',
]);
```

**@example**
Return all parent paths of a child path, including the child, to a depth of 2.

```typescript
import {
  parentPaths,
} from '@sqlpm/file-async-ts';

const paths = parentPaths('/a/b/c/d', { depth: 2 });
expect(paths).toEqual(['/a/b/c/d', '/a/b/c']);
```

## Intent

* No Emitted Javascript - The intent is to import this typescript library into a typescript project: compiling to Javascript occurring within the project.
* No Synchronous Calls Exposed - We [facade](https://en.wikipedia.org/wiki/Facade_pattern) only asynchronous functions as a forcing function to simplify architectural decisions. The intent is to add consistency to how files are consumed within a business organization.

## Development

See the [monorepo readme](https://www.github.com/erichosick/sqlpm).

## License

Licensed under MIT. See LICENSE.md.
