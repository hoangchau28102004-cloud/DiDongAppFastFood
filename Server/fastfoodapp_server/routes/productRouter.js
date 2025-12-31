import express from 'express';
import ProductController from '../controller/productsController.js';

const router = express.Router();

router.get('/products', ProductController.getAllProducts);
router.get('/products/:id',ProductController.getProductDetail);

export default router;