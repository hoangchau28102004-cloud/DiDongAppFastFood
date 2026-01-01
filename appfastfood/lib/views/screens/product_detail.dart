import 'package:flutter/material.dart';
import '../../models/products.dart';
import '../../service/api_service.dart';
import '../widget/custom_top_bar.dart';
import '../widget/custom_bottom_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ApiService _apiService = ApiService();
  int _currentBottomIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(children: [Text("Hello"), Icon(Icons.star)]),
        leading: Icon(Icons.arrow_back_ios_new),
        actions: [Icon(Icons.favorite)],
      ),

      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _currentBottomIndex,
        onItemTapped: (index) => setState(() => _currentBottomIndex = index),
      ),
    );
  }
}
