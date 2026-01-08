import db from '../config/db.js'; // Lưu ý: Phải có đuôi .js

export const getPromotions = (req, res) => {
    const sql = "SELECT * FROM promotions WHERE status = 1 ORDER BY start_date DESC";

    db.query(sql, (err, results) => {
        if (err) {
            console.error("Lỗi lấy khuyến mãi:", err);
            return res.status(500).json({ message: "Lỗi Server" });
        }
        res.status(200).json(results);
    });
};