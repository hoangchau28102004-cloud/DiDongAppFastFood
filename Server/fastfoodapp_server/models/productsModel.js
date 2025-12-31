import { execute } from '../config/db.js';

class ProductModel{
    static async getAll(){
        const sql = `
        SELECT p.*, c.name as category_name
        FROM Products p
        JOIN Categories c ON p.category_id = c.category_id
        WHERE p.status = 1 AND c.status = 1
        `
        const [rows] = await execute(sql);
        return rows;
    }

    static async getById(id){
        const sql = `SELECT * FROM Products WHERE product_id = ? AND Status = 1`
        const [rows] = await execute(sql,[id]);
        return rows[0];
    }
}

export default ProductModel;