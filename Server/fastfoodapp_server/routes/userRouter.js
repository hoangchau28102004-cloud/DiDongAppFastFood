import { Router } from 'express';
import userController from '../controller/userController.js';
import auth from '../middleware/auth.js';
import multer from 'multer';
import path from 'path';
import fs from 'fs';

const userRouter = Router();

// Tạo thư mục uploads nếu chưa có (tránh lỗi crash app)
const uploadDir = 'uploads/';
if (!fs.existsSync(uploadDir)){
    fs.mkdirSync(uploadDir);
}

const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, 'uploads/');
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + path.extname(file.originalname);
        cb(null, `user-${req.userId}-${uniqueSuffix}`);
    }
});

const fileFilter = (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
        cb(null, true);
    } else {
        cb(new Error('Chỉ được upload file ảnh!'), false);
    }
};

const upload = multer({ storage: storage, fileFilter: fileFilter });

// Public routes
userRouter.post('/login', userController.login);
userRouter.post('/register', userController.register);

// Routes quên mật khẩu
userRouter.post('/send-otp', userController.sendOtp);
userRouter.post('/reset-password', userController.resetPassword);

// Protected routes (Cần Token)
userRouter.get('/profile', auth, userController.profile);
userRouter.post('/profile/update', auth, upload.single('image'), userController.updateUserInfo);
userRouter.post('/logout', auth, userController.logout);

// Routes yêu thích (favorites)
userRouter.post('/favorites/add',auth,userController.addFavorites);
userRouter.get('/favorites/check',auth,userController.checkFavorites);
userRouter.post('/favorites/remove',auth,userController.removeFavorite);
userRouter.get('/favorites/list',auth,userController.getFavoriteList);

// Cart
userRouter.post('/carts/add',auth,userController.addToCart);
userRouter.get('/carts',auth,userController.getCart);
userRouter.put('/carts/update',auth,userController.updateCartItem);
userRouter.delete('/carts/delete',auth,userController.removeCartItem);
export default userRouter;