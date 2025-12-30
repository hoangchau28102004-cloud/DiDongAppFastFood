import { Router } from 'express';
import userController from '../controller/userController.js';
import auth from '../middleware/auth.js';

const userRouter = Router();

// Public routes
userRouter.post('/login', userController.login);
userRouter.post('/register', userController.register);

// Protected routes (Cần Token)
userRouter.get('/profile', auth, userController.profile);
userRouter.post('/logout', auth, userController.logout);

export default userRouter;