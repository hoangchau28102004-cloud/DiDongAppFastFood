import 'package:flutter/material.dart';
// 1. IMPORT CÁC FILE MODEL VÀ SERVICE CỦA BẠN VÀO ĐÂY
// (Sửa lại đường dẫn import cho đúng với thư mục của bạn nếu cần)
import '../../models/products.dart';
import '../../service/api_service.dart';

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedCategoryIndex = 0;

  // 2. KHAI BÁO BIẾN ĐỂ LƯU DỮ LIỆU TỪ API
  List<Product> _products = [];
  bool _isLoading = true; // Biến để kiểm tra xem đang tải hay xong rồi

  final List<Map<String, dynamic>> _categories = [
    {"name": "All", "icon": Icons.fastfood},
    {"name": "Burger", "icon": Icons.lunch_dining},
    {"name": "Pizza", "icon": Icons.local_pizza},
    {"name": "Drink", "icon": Icons.local_drink},
    {"name": "Snack", "icon": Icons.bakery_dining},
  ];

  // 3. GỌI API KHI MÀN HÌNH VỪA KHỞI TẠO
  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    try {
      // Gọi hàm lấy sản phẩm từ file api_service.dart
      List<Product> data = await ApiService().getAllProducts();

      setState(() {
        _products = data;
        _isLoading = false; // Đã tải xong, tắt loading
      });
    } catch (e) {
      print("Lỗi tải dữ liệu: $e");
      setState(() => _isLoading = false); // Có lỗi cũng tắt loading
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // --- HEADER & CATEGORY GIỮ NGUYÊN ---
          const CustomHomHeader(),
          const SizedBox(height: 15),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Categories",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) => _buildCategoryItem(index),
            ),
          ),
          const SizedBox(height: 10),

          // --- PHẦN HIỂN THỊ SẢN PHẨM (ĐÃ SỬA) ---
          Expanded(
            child: Container(
              color: Colors.white,
              // 4. KIỂM TRA: NẾU ĐANG TẢI THÌ HIỆN VÒNG XOAY, XONG THÌ HIỆN LIST
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.orange),
                    )
                  : ListView(
                      padding: EdgeInsets.zero,
                      physics: const BouncingScrollPhysics(),
                      children: [
                        const SizedBox(height: 20),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            "Popular Now",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Lưới sản phẩm thật
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(20),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 15,
                                childAspectRatio: 0.75,
                              ),
                          // Dùng số lượng thật từ API
                          itemCount: _products.length,
                          // Truyền dữ liệu Product vào hàm build card
                          itemBuilder: (context, index) =>
                              _buildProductCard(_products[index]),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFFFFC529),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(int index) {
    bool isSelected = _selectedCategoryIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 20),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? const Color(0xFFFFC529) : Colors.white,
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 5,
                      spreadRadius: 1,
                    ),
                ],
              ),
              child: Icon(
                _categories[index]['icon'],
                color: isSelected ? Colors.white : Colors.black54,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _categories[index]['name'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 5. SỬA HÀM NÀY ĐỂ NHẬN MODEL PRODUCT
  Widget _buildProductCard(Product product) {
    // Tạo đường dẫn ảnh đầy đủ (Base URL + Link ảnh từ DB)
    // Lưu ý: Đảm bảo link này đúng với IP máy bạn (dùng ApiService.baseUrl nếu đã khai báo public static)
    String imageUrl = "${ApiService.baseUrl}/${product.imageUrl}";

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh sản phẩm
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
              child: Container(
                color: Colors.grey[200],
                width: double.infinity,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  // Nếu ảnh lỗi hoặc chưa load được thì hiện icon
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.fastfood,
                      size: 40,
                      color: Colors.grey[400],
                    );
                  },
                ),
              ),
            ),
          ),
          // Thông tin sản phẩm
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name, // Tên thật
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis, // Cắt bớt nếu tên dài quá
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "\$${product.price}", // Giá thật
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Icon(
                      Icons.add_circle,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- CLASS HEADER (GIỮ NGUYÊN) ---
class CustomHomHeader extends StatelessWidget {
  const CustomHomHeader({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFC529),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Row(
                        children: [
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Search",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(bottom: 5),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFFF5722),
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  _buildIcon(Icons.shopping_cart_outlined),
                  const SizedBox(width: 10),
                  _buildIcon(Icons.notifications_outlined),
                ],
              ),
              const SizedBox(height: 25),
              const Text(
                "Good Morning",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(IconData icon) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(0.3),
      border: Border.all(color: Colors.white, width: 1.5),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );
}
