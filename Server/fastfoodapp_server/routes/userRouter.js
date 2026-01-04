import { Router } from 'express';
import userController from '../controller/userController.js';
import auth from '../middleware/auth.js';

const userRouter = Router();

// Public routes
userRouter.post('/login', userController.login);
userRouter.post('/register', userController.register);

// Routes quên mật khẩu
userRouter.post('/send-otp', userController.sendOtp);
userRouter.post('/reset-password', userController.resetPassword);

// Protected routes (Cần Token)
userRouter.get('/profile', auth, userController.profile);
userRouter.post('/logout', auth, userController.logout);

// Routes yêu thích (favorites)
userRouter.post('/favorites/add',auth,userController.addFavorites);
userRouter.get('/favorites/check',auth,userController.checkFavorites);
userRouter.post('/favorites/remove',auth,userController.removeFavorite);
userRouter.get('/favorites/list',auth,userController.getFavoriteList);
export default userRouter;