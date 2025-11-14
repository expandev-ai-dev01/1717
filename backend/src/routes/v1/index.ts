import { Router } from 'express';
import internalRoutes from './internalRoutes';
import externalRoutes from './externalRoutes';

const router = Router();

// Publicly accessible routes
router.use('/external', externalRoutes);

// Routes requiring authentication
router.use('/internal', internalRoutes);

export default router;
