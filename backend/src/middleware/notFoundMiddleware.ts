import { Request, Response } from 'express';
import { errorResponse } from '@/utils/responses/apiResponse';

/**
 * @summary
 * Handles requests for routes that do not exist.
 *
 * @param _req The Express request object.
 * @param res The Express response object.
 */
export function notFoundMiddleware(_req: Request, res: Response): void {
  res.status(404).json(errorResponse('NotFound', 'The requested resource was not found.'));
}
