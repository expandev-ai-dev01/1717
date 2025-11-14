import { Request, Response, NextFunction } from 'express';
import { listProducts } from '@/services/product/productService';
import { productListQuerySchema } from '@/services/product/productValidation';
import { successResponse, errorResponse } from '@/utils/responses/apiResponse';

/**
 * @summary
 * Handles the request for listing products from the public catalog.
 *
 * @param req The Express request object.
 * @param res The Express response object.
 * @param next The Express next function.
 */
export async function listHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    // Assume idAccount is 1 for this public-facing feature demo.
    // In a real multi-tenant app, this would come from the domain or a public user context.
    const idAccount = 1;

    const validationResult = productListQuerySchema.safeParse(req.query);

    if (!validationResult.success) {
      res
        .status(400)
        .json(
          errorResponse(
            'ValidationError',
            'Invalid query parameters.',
            validationResult.error.format()
          )
        );
      return;
    }

    const queryParams = { ...validationResult.data, idAccount };

    const result = await listProducts(queryParams);

    res.status(200).json(successResponse(result));
  } catch (error) {
    next(error);
  }
}
