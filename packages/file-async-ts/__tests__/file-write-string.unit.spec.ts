import {
  join,
} from 'node:path';

import {
  fileWrite,
  fileRemove,
  readFileString,
} from '../src/index';

describe('file mutate', () => {
  describe('fileRemove', () => {
    it(`should only return false if fileRemove
      is called on a file that does not exist`, async () => {
      const file = join(__dirname, 'somefile_does_not_exist.txt');
      expect(await fileRemove(file)).toEqual(false);
    });

    it(`should remove a file and return true
      on a file that exists`, async () => {
      const file = join(__dirname, 'test_file.txt');

      // clean up
      await fileRemove(file);
      await fileWrite(file, 'test');

      expect(await fileRemove(file)).toEqual(true);
    });
  });

  describe('fileWrite', () => {
    it('should write to a file one one does not exist', async () => {
      const file = join(__dirname, 'somefile.txt');
      const content = 'Hello. This is some text.';

      // clean up
      await fileRemove(file);

      await fileWrite(file, content);

      const result = await readFileString(file);
      expect(result).toEqual(content);

      // clean up
      await fileRemove(file);
    });

    it.skip(`should not append or overwrite a file
    that alread exists`, async () => {
      const file = join(__dirname, 'somefile2.txt');
      const content = 'Hello. This is some text.';
      const content2 = 'Should not write this.';

      // clean up
      await fileRemove(file);

      await fileWrite(file, content);

      const result = await readFileString(file);
      expect(result).toEqual(content);

      // TODO: This will, currently, overwrite the file. A feature
      // should be added where the overwrite only happens if an option
      // enables it.
      await fileWrite(file, content2);

      const result2 = await readFileString(file);
      expect(result2).toEqual(content);

      // clean up
      await fileRemove(file);
    });
  });
});
