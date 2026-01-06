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

    // Tìm user bằng ID (dùng cho profile)
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

    // Cập nhật thông tin user
    static async updateUser(userId, updateData) {
        try {
            const fields = [];
            const values = [];

            if (updateData.fullname) {
                fields.push('fullname = ?');
                values.push(updateData.fullname);
            }
            if (updateData.email) {
                fields.push('email = ?');
                values.push(updateData.email);
            }
            if (updateData.phone) {
                fields.push('phone = ?');
                values.push(updateData.phone);
            }
            if (updateData.birthday) {
                fields.push('BirthDay = ?');
                values.push(updateData.birthday);
            }
            if (updateData.image) {
                fields.push('Image = ?');
                values.push(updateData.image);
            }

            if (fields.length === 0) return { success: false, message: "Không có dữ liệu để cập nhật" };

            values.push(userId);
            const sql = `UPDATE Users SET ${fields.join(', ')} WHERE user_id = ?`;
            
            const [result] = await execute(sql, values);
            return { success: true, affectedRows: result.affectedRows };

        } catch (error) {
            throw new Error('Update user failed: ' + error.message);
        }
    }

    // Thêm sản phẩm yêu thích
    static async addFavorites(userId,productId){
        try{
            const [check] = await execute('SELECT * FROM favorites WHERE user_id = ? AND product_id = ?', [userId,productId]);
            if(check.length > 0){
                return { success: false, message: 'Sản phẩm này đã thích rồi' };
            }
            const [result] = await execute('INSERT INTO favorites(user_id,product_id,liked_at) VALUES(?,?,NOW())',
                [userId,productId]
            );
            return { success: true, message:"Vừa thích sản phẩm này" };
        }catch(e){
            console.error("Lỗi model Add Favorites")
            throw e;
        }
    }

    // Kiểm tra sản phẩm đã được yêu thích chưa
    static async checkFavorites(userId,productId){
        const [rows] = await execute('SELECT * FROM favorites WHERE user_id = ? AND product_id = ?',[userId,productId]);
        return rows.length > 0;
    }

    // Xóa sản phẩm yêu thích
    static async removeFavorites(userId,product_id){
        try {
            const [result] = await execute('DELETE FROM favorites WHERE user_id = ? AND product_id = ?',[userId,product_id]);
            return result.affectedRows > 0;
        } catch (error) {
            throw error;
        }
    }

    // Lấy danh sách sản phẩm yêu thích của User
    static async getFavoritesByUserId(userId) {
        try {
            const sql = `
                SELECT p.* FROM Products p
                JOIN Favorites f ON p.product_id = f.product_id
                JOIN Users u ON f.user_id = u.user_id
                WHERE u.user_id = ?
            `;
            const [rows] = await execute(sql, [userId]);
            return rows;
        } catch (error) {
            throw error;
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
    // Hàm này nhiều quá lười try catch deadline dí (T_T)
    static async checkItemInCart(user_id,product_id){
        const sql = `SELECT * FROM carts WHERE user_id = ? AND product_id = ?`;
        const [rows] = await execute(sql,[user_id,product_id]);
        return rows[0];
    }

    static async addToCart(user_id,product_id,quantity,note){
        const sql = `INSERT INTO carts(user_id,product_id,quantity,note)
        VALUES (?,?,?,?)
        `;
        return await execute(sql,[user_id,product_id,quantity,note]);
    }

    static async updateCart(cartId,quantity,note){
        const sql = `UPDATE carts SET quantity = ?, note = ? updated_at = NOW() WHERE cart_id = ?`;
        return await execute(sql,[cartId,quantity,note]);
    }

    static async getCartByUserId(userId){
        const sql = `
        SELECT c.cart_id, c.product_id, c.quantity, c.note, p.name, p.price, p.image_url 
        FROM Carts c
        JOIN Products p ON c.product_id = p.product_id
        WHERE c.user_id = ?
        `;
        const [rows] = await execute(sql,[userId]);
        return rows;
    }

    static async removeCartItem(cartId){
        const sql = `DELETE FROM carts WHERE cart_id = ?`;
        return await execute(sql,[cartId]);
    }
}