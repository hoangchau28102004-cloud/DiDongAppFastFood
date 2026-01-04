import 'package:appfastfood/views/screens/users/product_detail.dart';
import 'package:appfastfood/views/widget/product_card.dart';
import 'package:flutter/material.dart';
import '../../../models/products.dart';

class FavoriteContent extends StatelessWidget {
  final List<Product> favoriteProducts;
  final Future<List<Product>> productsFuture;
  final Future<List<Product>> Function() onRefresh;

  const FavoriteContent({
    super.key,
    required this.favoriteProducts,
    required this.productsFuture,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: FutureBuilder<List<Product>>(
          future: productsFuture, 
          builder: (context, snapshot) {
            if(snapshot.connectionState == ConnectionState.waiting){
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Lỗi: ${snapshot.error}'));
            } else if(!snapshot.hasData || snapshot.data!.isEmpty){
              return ListView(
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                        SizedBox(height: 10),
                        Text(
                          'Chưa có sản phẩm yêu thích', 
                          style: TextStyle(fontSize: 18, color: Colors.grey)
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            final List<Product> realFavoriteList = snapshot.data!;

            return ListView.separated(
              padding: const EdgeInsets.all(10),
              separatorBuilder: (context, index) => const SizedBox(height: 20), 
              itemCount: realFavoriteList.length,
              itemBuilder:(context, index) {
                final product = realFavoriteList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProductDetailScreen(product: product),
                      ),
                    );
                  },
                  child: ProductCard(product: product),
                );
              } ,
            );
          }
        ),
      )
    );
  }
}