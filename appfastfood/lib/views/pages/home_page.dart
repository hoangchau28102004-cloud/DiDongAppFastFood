import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePageScreen(),
    ),
  );
}

class HomePageScreen extends StatefulWidget {
  const HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  int _selectedCategoryIndex = 0;

  final List<Map<String, dynamic>> _categories = [
    {"name": "All", "icon": Icons.fastfood},
    {"name": "Burger", "icon": Icons.lunch_dining},
    {"name": "Pizza", "icon": Icons.local_pizza},
    {"name": "Drink", "icon": Icons.local_drink},
    {"name": "Snack", "icon": Icons.bakery_dining},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      // Cấu trúc chính là Column để xếp dọc các thành phần
      body: Column(
        children: [
          // ------------------------------------------------
          // 1. PHẦN CỐ ĐỊNH (HEADER + CATEGORY)
          // ------------------------------------------------

          // Header màu vàng (Giữ nguyên)
          const CustomHomHeader(),

          const SizedBox(height: 15),

          // Tiêu đề "Categories" (Cố định)
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

          // Danh sách Category (Cố định - chỉ cuộn ngang trong khu vực của nó)
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return _buildCategoryItem(index);
              },
            ),
          ),

          const SizedBox(
            height: 10,
          ), // Khoảng cách giữa Category và Lưới sản phẩm
          // ------------------------------------------------
          // 2. PHẦN CUỘN DỌC (POPULAR NOW + SẢN PHẨM)
          // ------------------------------------------------
          Expanded(
            // Expanded giúp phần này chiếm hết khoảng trống còn lại bên dưới
            child: Container(
              color: Colors
                  .white, // Nền trắng cho phần sản phẩm để tách biệt (tuỳ chọn)
              child: ListView(
                padding: EdgeInsets.zero, // Xóa padding mặc định
                physics: const BouncingScrollPhysics(), // Hiệu ứng cuộn
                children: [
                  const SizedBox(height: 20),

                  // Tiêu đề "Popular Now" (Sẽ bị cuộn đi khi kéo xuống)
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

                  // Lưới sản phẩm
                  GridView.builder(
                    shrinkWrap:
                        true, // Bắt buộc: để Grid nằm gọn trong ListView
                    physics:
                        const NeverScrollableScrollPhysics(), // Bắt buộc: để Grid không cuộn riêng, mà cuộn theo ListView cha
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15,
                          mainAxisSpacing: 15,
                          childAspectRatio: 0.75, // Tỷ lệ hình/khung
                        ),
                    itemCount: 8, // Giả lập 8 sản phẩm
                    itemBuilder: (context, index) => _buildProductCard(index),
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

  Widget _buildProductCard(int index) {
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
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
              ),
              child: Center(
                child: Icon(Icons.fastfood, size: 40, color: Colors.grey[400]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Product ${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "\$12.00",
                      style: TextStyle(
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
