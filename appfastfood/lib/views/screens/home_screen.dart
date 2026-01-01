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
  final TextEditingController _search = TextEditingController();

  late Future<List<Product>> _productsFuture;

  List<Product> _displayProducts = [];
  List<Product> _allProducts = [];
  List<String> _categories = ["All"];
  String _selectedCategory = "All";
  int _currentBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadData(); // Gọi hàm load data khi mở app
  }

  // 1. SỬA HÀM NÀY: Trả về Future để dùng cho RefreshIndicator
  Future<List<Product>> _loadData() async {
    final products = await _apiService.getAllProducts();

    if (mounted && products.isNotEmpty) {
      setState(() {
        _allProducts = products;

        // Reset lại bộ lọc hiển thị tất cả khi làm mới
        _displayProducts = products;
        _selectedCategory = "All";
        _search.clear(); // Xóa luôn ô tìm kiếm cho sạch

        final categorySet = products.map((p) => p.categoryName).toSet();
        _categories = ["All", ...categorySet];
      });
    }
    return products;
  }

  void _runFilter() {
    String keyword = _search.text.toLowerCase();
    String category = _selectedCategory;

    setState(() {
      if (keyword.isEmpty && category == "All") {
        _displayProducts = _allProducts;
      } else {
        _displayProducts = _allProducts.where((product) {
          bool matchName = product.name.toLowerCase().contains(keyword);
          bool matchCategory =
              (category == "All") || (product.categoryName == category);
          return matchName && matchCategory;
        }).toList();
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
          CustomTopBar(
            isHome: true,
            searchController: _search,
            onSearchChanged: (value) => _runFilter(),
          ),

          Expanded(
            child: FutureBuilder<List<Product>>(
              future: _productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    _allProducts.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE95322)),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Lỗi: ${snapshot.error}"));
                } else if (_allProducts.isEmpty) {
                  return const Center(child: Text("Không có dữ liệu"));
                }

                // Giao diện chính sau khi có dữ liệu
                return Column(
                  children: [
                    const SizedBox(height: 20),

                    // Danh sách Category (Giữ nguyên)
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
                            onTap: () {
                              setState(() => _selectedCategory = catName);
                              _runFilter();
                            },
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

                    // 2. PHẦN QUAN TRỌNG: LIST SẢN PHẨM CÓ KÉO LÀM MỚI
                    Expanded(
                      child: RefreshIndicator(
                        color: const Color(0xFFE95322),
                        onRefresh: _loadData, // Kéo xuống sẽ gọi lại hàm này
                        child: ListView.separated(
                          // 3. OPTIMIZE: Giúp lướt mượt hơn
                          physics:
                              const AlwaysScrollableScrollPhysics(), // Luôn cho phép kéo
                          cacheExtent:
                              1000, // Render trước 1000px bên dưới để không bị khựng

                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          separatorBuilder: (context, index) => const Column(
                            children: [
                              SizedBox(height: 10),
                              Divider(),
                              SizedBox(height: 10),
                            ],
                          ),
                          itemCount: _displayProducts.length,
                          itemBuilder: (context, index) {
                            final product = _displayProducts[index];
                            return GestureDetector(
                              onTap: () {
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
                    ),
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
