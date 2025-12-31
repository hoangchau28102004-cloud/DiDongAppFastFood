import productsModel from '../models/productsModel.js';

class ProductController{
    static async getAllProducts(req,res){
        try{
            const products = await productsModel.getAll();
        
            return res.status(200).json({
                success: true,
                message:'get success products list',
                data: products
            });
        }catch(error){
            console.error(error);
            return res.status(500).json({
                success: false,
                message: 'Error server when get products'
            });
        }
    }

    static async getProductDetail(req,res){
        try{
            const { id } = req.params;
            const product = await productsModel.getById(id);

            if(!product){
                return res.status(401).json({
                    success: false,
                    message: 'Not found product'
                });
            }

            return res.status(200).json({
                success: true,
                data: product
            });
        }catch(error){
            return res.status(500).json({
                success: false,
                message: 'Error server'
            });
        }
    }
}

export default ProductController;