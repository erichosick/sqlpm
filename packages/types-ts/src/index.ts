/**
 * Defines potential messaging/logging levels
 */
export type LogLevel =
  'error' |
  'warn' |
  'help' |
  'data' |
  'info' |
  'debug' |
  'prompt' |
  'verbose' |
  'input' |
  'silly' |
  'event';

/**
 * The start of a structured message for logging and events.
 * See [Structured Message Formats]https://medium.com/full-stack-architecture/structured-message-formats-thoughts-on-what-to-log-501306e916de
 * **@interface**
 * * **@member [{@link StructuredMessage.id}]**
 * * **@member {@link StructuredMessage.level}**
 * * **@member {@link StructuredMessage.message}**
 */
export interface StructuredMessage {

  /**
   * A unique id for the message. The id should be universally unique and
   * preferably sortable.
   */
  id?: string;

  /**
   * A log level enables a log message to be filtered based on the message's
   * importance.
   */
  level: LogLevel;

  /**
   * A simple human-readable message. The message is the final formatted
   * message requiring no further processing.
   */
  message: string;
}

/**
 * Function signature for {@link StructuredMessenger}.
 */

export type StructuredMessageSignature = (
  message: StructuredMessage
) => void;

/**
 *
 *
 * **@interface**
 * * **@member {@link StructuredMessenger.debug}**
 * * **@member {@link StructuredMessenger.error}**
 * * **@member {@link StructuredMessenger.info}**
 * * **@member {@link StructuredMessenger.warn}**
 *
 */
export interface StructuredMessenger {

  /**
   * Send a debug level message.
   */
  debug: (message: string) => void;

  /**
   * Send an error level message.
   */
  error: (message: string) => void;

  /**
   * Send an info level message.
   */
  info: (message: string) => void;

  /**
   * Send a warning (warn) level message.
   */
  warn: (message: string) => void;
}

/**
 * Options that are common between all functions.
 *
 * **@interface**
 * * **@member [{@link CommonOptions.sendMsg}]**
 */
export interface CommonOptions {

  /**
   * One or more ways of sending a message, event, log, etc. Call one of the
   * helper methods such as sendMsg.info.
   */
  sendMsg?: StructuredMessenger,
}
