import { Request, Response, NextFunction } from 'express';
import { errorResponse } from '@/utils/responses/apiResponse';
import { logger } from '@/utils/logger/logger';

/**
 * @summary
 * Global error handling middleware. Catches errors from route handlers and
 * formats a standardized error response.
 *
 * @param err The error object.
 * @param _req The Express request object.
 * @param res The Express response object.
 * @param _next The Express next function.
 */
export function errorMiddleware(
  err: Error,
  _req: Request,
  res: Response,
  _next: NextFunction
): void {
  logger.error('An unexpected error occurred', {
    message: err.message,
    stack: err.stack,
  });

  res.status(500).json(errorResponse('InternalServerError', 'An unexpected error occurred.'));
}
