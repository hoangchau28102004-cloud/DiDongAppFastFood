import 'package:appfastfood/views/screens/home_interface/favorite_content.dart';
import 'package:appfastfood/views/screens/home_interface/home_content.dart';
import 'package:flutter/material.dart';
import '../../models/products.dart';
import '../../service/api_service.dart';
import '../widget/custom_top_bar.dart';
import '../widget/custom_bottom_bar.dart';
import '../widget/side_menu.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _search = TextEditingController();

  late Future<List<Product>> _productsFuture;
  late Future<List<Product>> _favoriteFuture;

  List<Product> _homeDisplayProducts = [];
  List<Product> _homeAllProducts = [];
  List<String> _categories = ["All"];
  String _selectedCategory = "All";
  int _currentBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadHomeData();
    
    // Lắng nghe ô tìm kiếm
    _search.addListener(() {
      if (_currentBottomIndex == 0) {
        _filterProducts(_search.text);
      }
    });

    _favoriteFuture = _loadFavData();
  }

  // Hàm load dữ liệu và cập nhật State cho Home
  Future<List<Product>> _loadHomeData() async {
    final products = await _apiService.getAllProducts();
    _search.clear();

    if (mounted && products.isNotEmpty) {
      setState(() {
        _homeAllProducts = products;
        _homeDisplayProducts = products;
        
        final categories = products
            .map((p) => p.categoryName)
            .toSet()
            .toList();
        _categories = ["All", ...categories];
        _selectedCategory = "All";
      });
    }
    return products;
  }

  // Hàm refresh cho Home
  Future<List<Product>> _refreshHome() async {
    setState(() {
      _productsFuture = _loadHomeData();
    });
    return _productsFuture;
  }

  // Hàm lọc sản phẩm theo search text
  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _homeDisplayProducts = _homeAllProducts);
    } else {
      setState(() {
        _homeDisplayProducts = _homeAllProducts
            .where((p) => p.name!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  // Hàm load dữ liệu cho Favorite
  Future<List<Product>> _loadFavData() async {
    setState(() {
      _favoriteFuture = _apiService.getFavoriteList();
    });
    return _favoriteFuture;
  }

  // Hàm lọc theo danh mục
  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == "All") {
        _homeDisplayProducts = _homeAllProducts;
      } else {
        _homeDisplayProducts = _homeAllProducts
            .where((p) => p.categoryName == category)
            .toList();
      }
    });
  }

  Widget _getBodyContent() {
    switch (_currentBottomIndex) {
      case 0:
        return HomeContent(
          categories: _categories,
          selectedCategory: _selectedCategory,
          displayProducts: _homeDisplayProducts,
          productsFuture: _productsFuture,
          onCategorySelected: _filterByCategory,
          onRefresh: _refreshHome,
        );
      case 1:
        return const Center(child: Text("Màn hình Order (Đang phát triển)"));
      case 2:
        return FavoriteContent(
          favoriteProducts: [], 
          productsFuture: _favoriteFuture, 
          onRefresh: _loadFavData
        );
      case 3:
        return const Center(child: Text("Màn hình Lịch sử (Đang phát triển)"));
      case 4:
        return const Center(child: Text("Màn hình Hỗ trợ (Đang phát triển)"));
      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      endDrawer: const SideMenu(),
      body: Column(
        children: [
          // TOP BAR
          CustomTopBar(
            isHome: _currentBottomIndex == 0, // Chỉ hiện lời chào "Good Morning" ở trang Home
            searchController: _search,
          ),

          //NỘI DUNG THAY ĐỔI
          Expanded(
            child: _getBodyContent(),
          ),
        ],
      ),

      // BOTTOM BAR
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _currentBottomIndex,
        onItemTapped: (index) {
          setState(() {
            _currentBottomIndex = index;
            if (index == 2) {
               _loadFavData(); 
            }
          });
        },
      ),
    );
  }
}
