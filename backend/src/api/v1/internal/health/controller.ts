import { Request, Response } from 'express';
import { successResponse } from '@/utils/responses/apiResponse';

/**
 * @summary
 * Handles the health check request for internal services.
 *
 * @param _req The Express request object.
 * @param res The Express response object.
 */
export async function getHandler(_req: Request, res: Response): Promise<void> {
  res.status(200).json(successResponse({ status: 'ok' }));
}
