import { execute, beginTransaction, commitTransaction, rollbackTransaction } from '../config/db.js';

export default class userModel {
    // Tìm user để đăng nhập (Join giữa Account và Users)
    static async findByUsername(username) {
        try {
            const sql = `
                SELECT 
                    a.account_id, a.Username, a.password, a.role, a.status,
                    u.user_id, u.fullname, u.email, u.phone, u.Image
                FROM Account a
                LEFT JOIN Users u ON a.account_id = u.account_id
                WHERE a.Username = ? 
                LIMIT 1
            `;
            const [rows] = await execute(sql, [username]);
            return rows[0] ?? null;
        } catch (error) {
            throw new Error('Database query failed: ' + error.message);
        }
    }

    // Đăng ký tài khoản mới (Sử dụng Transaction)
    static async create({ username, hashedPassword, fullname, email, phone }) {
        let connection;
        try {
            // 1. Bắt đầu transaction
            connection = await beginTransaction();

            // 2. Thêm vào bảng Account
            const [accountResult] = await connection.execute(
                'INSERT INTO Account(Username, password, role, status) VALUES(?, ?, ?, ?)',
                [username, hashedPassword, 'CUSTOMER', 1]
            );
            const accountId = accountResult.insertId;

            // 3. Thêm vào bảng Users
            await connection.execute(
                'INSERT INTO Users(account_id, fullname, email, phone) VALUES(?, ?, ?, ?)',
                [accountId, fullname, email, phone]
            );

            // 4. Commit (Lưu thay đổi)
            await commitTransaction(connection);
            
            return accountId;
        } catch (error) {
            // 5. Rollback nếu có lỗi (Hủy thay đổi)
            if (connection) await rollbackTransaction(connection);
            throw new Error('Registration failed: ' + error.message);
        }
    }

    static async findById(id) {
        try {
             const sql = `
                SELECT 
                    a.account_id, a.Username, a.role,
                    u.user_id, u.fullname, u.email, u.phone, u.BirthDay, u.Image
                FROM Account a
                LEFT JOIN Users u ON a.account_id = u.account_id
                WHERE a.account_id = ?
            `;
            const [rows] = await execute(sql, [id]);
            return rows[0] ?? null;
        } catch (error) {
            throw new Error('Database query failed: ' + error.message);
        }
    }

    // Tìm user bằng Email để gửi OTP
    static async findByEmail(email) {
        try {
            const sql = `
                SELECT 
                    a.account_id, a.Username, a.status,
                    u.user_id, u.fullname, u.email
                FROM Users u
                JOIN Account a ON u.account_id = a.account_id
                WHERE u.email = ?
            `;
            const [rows] = await execute(sql, [email]);
            return rows[0] ?? null;
        } catch (error) {
            throw new Error('Database query failed: ' + error.message);
        }
    }

    // Cập nhật mật khẩu mới
    static async updatePassword(accountId, newHashedPassword) {
        try {
            const sql = 'UPDATE Account SET password = ? WHERE account_id = ?';
            await execute(sql, [newHashedPassword, accountId]);
            return true;
        } catch (error) {
            throw new Error('Update password failed: ' + error.message);
        }
    }
}