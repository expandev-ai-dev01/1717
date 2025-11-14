import { Router } from 'express';
import * as healthController from '@/api/v1/internal/health/controller';

const router = Router();

// Internal health check to verify service is up
router.get('/health', healthController.getHandler);

// FEATURE INTEGRATION POINT: Add internal (authenticated) routes here.
// Example: router.use('/orders', orderRoutes);

export default router;
