import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { getProductById } from '@/services/product/productService';
import { successResponse, errorResponse } from '@/utils/responses/apiResponse';

const paramsSchema = z.object({
  id: z.coerce.number().int().positive('Product ID must be a positive integer.'),
});

/**
 * @summary
 * Handles the request for fetching a single product's details.
 *
 * @param req The Express request object.
 * @param res The Express response object.
 * @param next The Express next function.
 */
export async function getHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const validationResult = paramsSchema.safeParse(req.params);

    if (!validationResult.success) {
      res
        .status(400)
        .json(
          errorResponse('ValidationError', 'Invalid product ID.', validationResult.error.format())
        );
      return;
    }

    // Assume idAccount is 1 for this public-facing feature demo.
    const idAccount = 1;
    const { id: idProduct } = validationResult.data;

    const product = await getProductById({ idAccount, idProduct });

    if (!product) {
      res.status(404).json(errorResponse('NotFound', 'Product not found.'));
      return;
    }

    res.status(200).json(successResponse(product));
  } catch (error) {
    next(error);
  }
}
