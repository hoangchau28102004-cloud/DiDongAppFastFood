import 'package:appfastfood/service/api_service.dart';
import 'package:appfastfood/utils/storage_helper.dart';
import 'package:flutter/material.dart';
import '../../models/products.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  bool _isLoggedIn = false;
  int? _userId;
  bool isLiking = false;
  bool isFav = false;

  @override
  void initState() {
    super.initState();
    _checkFav();
  }

  void _checkFav() async {
    await _checkLoginStatus();
    if (_isLoggedIn) {
      bool isLiked = await ApiService().checkFav(widget.product.id);
      if (mounted) {
        setState(() {
          isFav = isLiked;
        });
      }
    }
  }

  void _onLiked() async {
    if (isLiking) return;
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bạn cần đăng nhập!")));
      return;
    }
    setState(() {
      isLiking = true;
    });
    if (isFav) {
      bool success = await ApiService().removeFavorite(widget.product.id);
      if (success) {
        setState(() {
          isFav = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn vừa xóa khỏi món ăn yêu thich")),
        );
      }
    } else {
      bool success = await ApiService().addFavorites(widget.product.id);
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Đã thêm vào yêu thích!")));
        setState(() {
          isFav = true;
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Thích chưa thành công")));
      }
    }
    setState(() {
      isLiking = false;
    });
  }

  Future<void> _checkLoginStatus() async {
    final token = await StorageHelper.getToken();
    final userId = await StorageHelper.getUserId();
    if (mounted) {
      setState(() {
        _isLoggedIn = (token != null && token.isNotEmpty);
        if (userId != null) _userId = userId;
      });
    }
  }

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE95322);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFFC529),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isLoggedIn)
            IconButton(
              onPressed: () {
                _onLiked();
              },
              icon: isFav
                  ? Icon(Icons.favorite, color: Colors.red)
                  : Icon(Icons.favorite_border_outlined, color: Colors.white),
            ),
        ],
      ),
      // Mở rộng body lên phần AppBar nếu muốn ảnh nền full
      extendBodyBehindAppBar: true,

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. ẢNH SẢN PHẨM
            Container(
              height: 350,
              width: double.infinity,
              color: Colors.grey[100], // Màu nền tạm khi chưa load ảnh
              child: widget.product.imageUrl.isNotEmpty
                  ? Image.network(
                      widget.product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                        child: Icon(Icons.image_not_supported, size: 50),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.image_not_supported, size: 50),
                    ),
            ),

            // 2. PHẦN THÔNG TIN (Bo tròn kéo lên trên ảnh một chút cho đẹp)
            Container(
              transform: Matrix4.translationValues(0.0, -30.0, 0.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thanh ngang nhỏ trang trí
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tên sản phẩm & Giá
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${widget.product.price}đ",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildQuantityButton(
                            Icons.remove,
                            _decrementQuantity,
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              "$_quantity",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          _buildQuantityButton(Icons.add, _incrementQuantity),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.product.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Rating và Thời gian (Giả lập)
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.product.averageRating}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 20),
                      const Icon(
                        Icons.access_time,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "15-20 phút",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Mô tả
                  const Text(
                    "Mô tả",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    width: 400,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 160, 160, 160),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      widget.product.description ??
                          'Chưa có mô tả cho sản phẩm này.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  const SizedBox(height: 50),
                  // Khoảng trống dưới cùng để không bị che
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  "Tổng tiền: ",
                  style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0)),
                ),
              ),
              Expanded(
                child: Align(
                  alignment: AlignmentGeometry.bottomRight,
                  child: Text(
                    "${widget.product.price * _quantity} VNĐ",
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
          SizedBox(height: 10),
          Divider(),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(onPressed: () {}, icon: Icon(Icons.chat)),
              ),
              SizedBox(
                height: 45, // QUAN TRỌNG: Phải set chiều cao cho đường kẻ
                child: VerticalDivider(
                  color: primaryColor, // Màu xám
                  thickness: 1, // Độ dày nét vẽ
                  width:
                      20, // Khoảng cách đệm (giống margin left/right gộp lại)
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.shopping_cart_checkout_outlined),
                ),
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (_isLoggedIn) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Mua thành công sản phẩm"),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vui lòng đăng nhập tài khoản"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.all(10),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadiusGeometry.circular(10),
                    ),
                  ),
                  child: Text("Mua với voucher"),
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }

  // Widget nút tăng giảm số lượng
  Widget _buildQuantityButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 244, 148, 3),
        borderRadius: BorderRadius.circular(50),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        // splashRadius: 20,
      ),
    );
  }
}
