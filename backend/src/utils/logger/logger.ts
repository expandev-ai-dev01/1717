/**
 * @summary
 * A simple logger utility. In a real application, this would be replaced
 * with a more robust logging library like Winston or Pino.
 */

const log = (level: string, message: string, meta?: object) => {
  const timestamp = new Date().toISOString();
  const logObject = {
    timestamp,
    level,
    message,
    ...meta,
  };
  console.log(JSON.stringify(logObject));
};

export const logger = {
  info: (message: string, meta?: object) => {
    log('info', message, meta);
  },
  warn: (message: string, meta?: object) => {
    log('warn', message, meta);
  },
  error: (message: string, meta?: object) => {
    log('error', message, meta);
  },
};
