import express from 'express';
import { getPromotions } from '../controller/promotionController.js'; // Nhớ thêm đuôi .js

const router = express.Router();

router.get('/', getPromotions);

export default router;