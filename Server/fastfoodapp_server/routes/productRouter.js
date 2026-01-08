import express from 'express';
import ProductController from '../controller/productsController.js';

const router = express.Router();

// 1. Lấy danh sách (App gọi: /api/products)
router.get('/products', ProductController.getAllProducts);

// 2. Lọc sản phẩm (App gọi: /api/products/filter)
// QUAN TRỌNG: Phải để dòng này TRƯỚC dòng /:id
router.get('/products/filter', ProductController.filterProducts);

// 3. Lấy chi tiết (App gọi: /api/products/123)
router.get('/products/:id', ProductController.getProductDetail);

export default router;