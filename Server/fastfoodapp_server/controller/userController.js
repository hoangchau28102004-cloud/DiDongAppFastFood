import { hash, compare } from 'bcrypt';
import jwt from 'jsonwebtoken';
import userModel from '../models/userModel.js';
import dotenv from 'dotenv';
dotenv.config();

const JWT_SECRET = process.env.JWT_SECRET;
const JWT_EXPIRES_IN = process.env.JWT_EXPIRES_IN || '8h';
const PASSWORD_HASH_ROUNDS = parseInt(process.env.PASSWORD_HASH_ROUNDS) || 10;

export default class userController {

    // 1. Hàm kiểm tra độ mạnh mật khẩu
    static validatePassword(password) {
        const passwordRule = {
            minLength: 8,
            maxLength: 100,
            requiredUpperCase: true,
            requiredLowerCase: true,
            requiredNumber: true,
            requiredSpecial: true
        };

        if (password.length < passwordRule.minLength || password.length > passwordRule.maxLength)
            return false;
        if (passwordRule.requiredUpperCase && !/[A-Z]/.test(password))
            return false;
        if (passwordRule.requiredLowerCase && !/[a-z]/.test(password))
            return false;
        if (passwordRule.requiredNumber && !/[0-9]/.test(password))
            return false;
        if (passwordRule.requiredSpecial && !/[!@#$%^&*(),.?":{}|<>]/.test(password)) {
            return false;
        }
        return true;
    }

    // Hàm tạo token
    static generateToken(user) {
        return jwt.sign(
            {
                id: user.account_id,
                username: user.Username,
                role: user.role
            },
            JWT_SECRET,
            { expiresIn: JWT_EXPIRES_IN }
        );
    }

    // Đăng ký
    static async register(req, res) {
        try {
            const { username, password, email, phone, fullname } = req.body;

            // Validate dữ liệu đầu vào
            if (!username || !password || !fullname) {
                return res.status(400).json({ success: false, message: 'Vui lòng nhập đầy đủ: username, password, fullname' });
            }

            // 2. Gọi hàm kiểm tra mật khẩu
            if (!userController.validatePassword(password)) {
                return res.status(400).json({
                    success: false,
                    message: 'Mật khẩu yếu! Cần ít nhất 8 ký tự, bao gồm chữ hoa, chữ thường, số và ký tự đặc biệt.'
                });
            }

            // Kiểm tra username đã tồn tại chưa
            const existingUser = await userModel.findByUsername(username);
            if (existingUser) {
                return res.status(400).json({ success: false, message: 'Username đã tồn tại' });
            }

            // 3. Mã hóa mật khẩu
            const hashedPassword = await hash(password, PASSWORD_HASH_ROUNDS);

            // Tạo user mới (Lưu vào 2 bảng Account và Users)
            const newAccountId = await userModel.create({
                username,
                hashedPassword,
                fullname,
                email,
                phone
            });

            res.status(201).json({
                success: true,
                message: "Đăng ký thành công",
                userId: newAccountId
            });

        } catch (error) {
            console.error(error);
            res.status(500).json({ success: false, message: error.message });
        }
    }

    // Đăng nhập
    static async login(req, res) {
        try {
            const { username, password } = req.body;

            if (!username || !password) {
                return res.status(400).json({ success: false, message: 'Vui lòng nhập username và password' });
            }

            // Tìm user trong DB
            const user = await userModel.findByUsername(username);
            if (!user) {
                return res.status(401).json({ success: false, message: 'Sai thông tin đăng nhập' });
            }

            // 4. So sánh mật khẩu nhập vào với mật khẩu đã mã hóa trong DB
            const isMatch = await compare(password, user.password);
            if (!isMatch) {
                return res.status(401).json({ success: false, message: 'Sai thông tin đăng nhập' });
            }

            // Kiểm tra trạng thái tài khoản
            if (user.status === 0) {
                return res.status(403).json({ success: false, message: 'Tài khoản đã bị khóa' });
            }

            // Tạo token
            const token = userController.generateToken(user);

            // Loại bỏ password khỏi dữ liệu trả về client
            const { password: _, ...userData } = user;

            res.status(200).json({
                success: true,
                message: "Đăng nhập thành công",
                token: token,
                user: userData
            });

        } catch (error) {
            console.error(error);
            res.status(500).json({ success: false, message: "Lỗi Server" });
        }
    }

    // Xem Profile
    static async profile(req, res) {
        try {
            const userId = req.userId;
            const user = await userModel.findById(userId);

            if (!user) {
                return res.status(404).json({ success: false, message: 'Không tìm thấy người dùng' });
            }

            res.status(200).json({
                success: true,
                user: user
            });
        } catch (error) {
            res.status(500).json({ success: false, message: error.message });
        }
    }
    // Logout
    static async logout(req, res) {
        try {
            res.status(200).json({
                success: true,
                message: 'Đăng xuất thành công'
            });

        } catch (error) {
            res.status(500).json({ success: false, message: 'Lỗi server' });
        }
    }
}