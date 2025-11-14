import { Router } from 'express';
import * as productListController from '@/api/v1/external/public/product/controller';
import * as productDetailController from '@/api/v1/external/public/product/detail/controller';

const router = Router();

// GET /api/v1/external/product - List products with filters
router.get('/', productListController.listHandler);

// GET /api/v1/external/product/:id - Get product details
router.get('/:id', productDetailController.getHandler);

export default router;
