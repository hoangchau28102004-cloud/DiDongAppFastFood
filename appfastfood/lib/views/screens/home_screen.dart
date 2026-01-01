import 'package:flutter/material.dart';
import '../../models/products.dart';
import '../../service/api_service.dart';
import '../widget/custom_top_bar.dart';
import '../widget/custom_bottom_bar.dart';
import '../widget/product_card.dart';
import '../widget/side_menu.dart';
import '../screens/product_detail.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final ApiService _apiService = ApiService();

  // Future chứa danh sách sản phẩm gốc
  late Future<List<Product>> _productsFuture;

  // Danh sách sản phẩm đang hiển thị (sau khi lọc)
  List<Product> _displayProducts = [];
  List<Product> _allProducts = [];

  // Danh sách danh mục (tự động lấy từ API)
  List<String> _categories = ["All"];
  String _selectedCategory = "All";
  int _currentBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _productsFuture = _apiService.getAllProducts().then((products) {
      if (products.isNotEmpty) {
        setState(() {
          _allProducts = products;
          _displayProducts = products;

          // Lấy danh sách category duy nhất từ sản phẩm
          final categorySet = products.map((p) => p.categoryName).toSet();
          _categories = ["All", ...categorySet];
        });
      }
      return products;
    });
  }

  void _filterProducts(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == "All") {
        _displayProducts = _allProducts;
      } else {
        _displayProducts = _allProducts
            .where((p) => p.categoryName == category)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      endDrawer: const SideMenu(),
      body: Column(
        children: [
          // 1. Top Bar (isHome = true để hiện lời chào)
          const CustomTopBar(isHome: true),

          // 2. Nội dung chính
          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE95322)),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Không có dữ liệu"));
                }

                return Column(
                  children: [
                    const SizedBox(height: 20),
                    // Danh sách Category
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final catName = _categories[index];
                          final isSelected = catName == _selectedCategory;
                          return GestureDetector(
                            onTap: () => _filterProducts(catName),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFE95322)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: isSelected
                                    ? null
                                    : Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                catName,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Grid Sản phẩm
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 15,
                        ),
                        physics: const BouncingScrollPhysics(),
                        separatorBuilder: (context, index) {
                          return Column(
                            children: [
                              SizedBox(height: 10),
                              Divider(),
                              SizedBox(height: 10),
                            ],
                          );
                        },

                        itemCount: _displayProducts.length,
                        itemBuilder: (context, index) {
                          final product =
                              _displayProducts[index]; // Lấy sản phẩm ra biến

                          // BỌC PRODUCT CARD TRONG GESTURE DETECTOR
                          return GestureDetector(
                            onTap: () {
                              // Điều hướng sang trang chi tiết
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                            },
                            child: ProductCard(product: product),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _currentBottomIndex,
        onItemTapped: (index) => setState(() => _currentBottomIndex = index),
      ),
    );
  }
}
