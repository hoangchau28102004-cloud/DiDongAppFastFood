import { execute } from '../config/db.js';

class ProductModel {
    // 1. Lấy tất cả (Giữ nguyên)
    static async getAll() {
        const sql = `
            SELECT p.*, c.name as category_name
            FROM Products p
            JOIN Categories c ON p.category_id = c.category_id
            WHERE p.status = 1 AND c.status = 1
            ORDER BY p.product_id DESC
        `;
        const [rows] = await execute(sql);
        return rows;
    }

    // 2. Chi tiết (Giữ nguyên)
    static async getById(id) {
        const sql = `SELECT p.*, c.name as category_name FROM Products p JOIN Categories c ON p.category_id = c.category_id WHERE p.product_id = ?`;
        const [rows] = await execute(sql, [id]);
        return rows[0];
    }

    // 3. Review (Giữ nguyên)
    static async getReviewProductId(id) {
        const sql = `SELECT r.*, u.fullname, u.image FROM reviews r JOIN users u ON r.user_id = u.user_id WHERE r.product_id = ? ORDER BY r.review_date DESC`;
        const [rows] = await execute(sql, [id]);
        return rows;
    }

    // --- 4. HÀM LỌC "ĐA NĂNG" (SỬA LẠI CHỖ NÀY) ---
   static async filter({ categoryId, minPrice, maxPrice, rating, keyword }) {
        // [LOG 1] Kiểm tra dữ liệu đầu vào nhận được từ Controller
        console.log("\n========== BẮT ĐẦU DEBUG FILTER ==========");
        console.log("1. Input params nhận được:", { categoryId, minPrice, maxPrice, rating, keyword });

        // SQL: Join bảng khuyến mãi để tính giá thực tế (final_price)
        let sql = `
            SELECT 
                p.*, 
                c.name as category_name,
                -- Tính giá sau giảm (Nếu có KM thì tính, ko thì lấy giá gốc)
                CAST(
                    CASE 
                        WHEN prom.discount_percent IS NOT NULL THEN p.price * (1 - prom.discount_percent / 100)
                        ELSE p.price 
                    END AS DECIMAL(15,2)
                ) AS final_price,
                prom.discount_percent
            FROM Products p
            JOIN Categories c ON p.category_id = c.category_id
            -- Join Khuyến mãi
            LEFT JOIN Promotion_Details pd ON (pd.product_id = p.product_id OR pd.category_id = p.category_id) AND pd.status = 1
            LEFT JOIN Promotions prom ON pd.promotion_id = prom.promotion_id 
                AND prom.status = 1 
                AND NOW() BETWEEN prom.start_date AND prom.end_date
            WHERE p.status = 1 AND c.status = 1
        `;
        
        const params = [];

        // 1. LỌC DANH MỤC
        if (categoryId && categoryId !== 'All' && categoryId !== '0') {
            sql += " AND p.category_id = ?";
            params.push(categoryId);
            console.log("-> [Logic] Đã áp dụng lọc Category ID:", categoryId);
        }

        // 2. LỌC RATING (Chỉ lọc khi user chọn sao > 0)
        // Ép kiểu sang Number để chắc chắn so sánh đúng
        if (rating && Number(rating) > 0) {
            sql += " AND p.average_rating >= ?";
            params.push(Number(rating));
            console.log("-> [Logic] Đã áp dụng lọc Rating >=", rating);
        }

        // 3. LỌC GIÁ: chỉ áp dụng khi min/max là số hợp lệ
        let havingClause = '';
        // Kiểm tra kỹ null, undefined và rỗng
        if (minPrice != null && maxPrice != null && minPrice !== '' && maxPrice !== '') {
            const min = Number(minPrice);
            const max = Number(maxPrice);
            
            if (!Number.isNaN(min) && !Number.isNaN(max)) {
                havingClause = ' HAVING final_price BETWEEN ? AND ?';
                params.push(min, max);
                console.log(`-> [Logic] Đã áp dụng lọc Giá: ${min} - ${max}`);
            } else {
                console.log("-> [Warning] Giá trị minPrice hoặc maxPrice không phải là số hợp lệ (NaN). Bỏ qua lọc giá.");
            }
        }

        // GROUP BY để tránh trùng sản phẩm khi join khuyến mãi và để HAVING hoạt động đúng
        sql += ' GROUP BY p.product_id';
        if (havingClause) sql += havingClause;

        sql += " ORDER BY p.product_id DESC";
        
        // [LOG 2] In ra câu lệnh SQL cuối cùng và danh sách tham số
        // Copy dòng SQL này vào phpMyAdmin để chạy thử nếu cần
        console.log("2. SQL Query cuối cùng:", sql); 
        console.log("3. Params (Các dấu ? sẽ được thay bằng):", params);

        try {
            const [rows] = await execute(sql, params);
            
            // [LOG 3] Kết quả trả về
            console.log(`4. Kết quả tìm thấy: ${rows.length} sản phẩm.`);
            // console.log("Dữ liệu chi tiết:", rows); // Bỏ comment dòng này nếu muốn xem chi tiết từng món
            console.log("========== KẾT THÚC DEBUG FILTER ==========\n");
            
            return rows;
        } catch (error) {
            console.error("!!! LỖI SQL FILTER !!!:", error);
            return [];
        }
    }
}

export default ProductModel;