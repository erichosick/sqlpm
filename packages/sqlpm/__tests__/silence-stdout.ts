// utils.ts
import { Writable } from 'stream';

class NullWritableStream extends Writable {
  _write(chunk: string | Uint8Array, encoding: BufferEncoding, callback: (err?: Error) => void): void {
    callback();
  }
}

function silenceStdout() {
  const originalStdoutWrite = process.stdout.write;
  const nullStream = new NullWritableStream();

  process.stdout.write = ((chunk: string | Uint8Array, encoding?: BufferEncoding, cb?: (err?: Error) => void): boolean => {
    nullStream.write(chunk, encoding as BufferEncoding);
    return true;
  }) as typeof process.stdout.write;

  return () => {
    process.stdout.write = originalStdoutWrite;
  };
}

export default silenceStdout;