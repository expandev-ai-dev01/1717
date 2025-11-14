import { Router } from 'express';
import productRoutes from './productRoutes';

const router = Router();

// FEATURE INTEGRATION POINT: Add external (public) routes here.
router.use('/product', productRoutes);

export default router;
