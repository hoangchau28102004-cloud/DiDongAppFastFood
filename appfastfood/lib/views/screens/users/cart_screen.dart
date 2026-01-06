import 'package:appfastfood/models/cartItem.dart';
import 'package:appfastfood/service/api_service.dart';
// Đổi đường dẫn import này cho đúng với project của bạn
import 'package:appfastfood/views/widget/product_card_cart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItem> _cartItem = [];
  bool _isLoading = true;
  double _subTotal = 0.0; // Tổng phụ
  double _discount = 0.3; // Khuyến mãi 30% (ví dụ fix cứng giống ảnh)
  final currentFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var items = await ApiService().getCartList();
      if (mounted) {
        setState(() {
          _cartItem = items;
          _calculateTotal();
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _calculateTotal() {
    double temp = 0;
    for (var item in _cartItem) {
      temp += item.price * item.quantity;
    }
    setState(() {
      _subTotal = temp;
    });
  }

  Future<void> _updateItem(int index, int newQuantity, String newNote) async {
    final item = _cartItem[index];
    if (newQuantity <= 0) {
      // Xử lý xóa item nếu cần (hoặc hỏi xác nhận trước khi xóa)
      setState(() {
        _cartItem.removeAt(index);
        _calculateTotal();
      });
      // Gọi API xóa item ở đây nếu có
    } else {
      setState(() {
        item.quantity = newQuantity;
        _calculateTotal();
      });
    }
    await ApiService().updateCart(item.cartId, newQuantity, newNote);
  }

  @override
  Widget build(BuildContext context) {
    // Tính toán số liệu hiển thị
    double discountAmount = _subTotal * _discount;
    double finalTotal = _subTotal - discountAmount;

    return Scaffold(
      backgroundColor: Colors.grey[50], // Màu nền nhẹ
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC529), // Màu vàng
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Giỏ Hàng",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // --- Dòng thông báo số lượng ---
                    Text(
                      "Bạn Có ${_cartItem.length} Món Ăn Trong Giỏ Hàng",
                      style: const TextStyle(
                        color: Color(0xFFE95322),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- Danh sách sản phẩm ---
                    // Dùng ListView.builder để render danh sách
                    _cartItem.isEmpty
                        ? const Center(child: Text("Giỏ hàng trống"))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _cartItem.length,
                            itemBuilder: (context, index) {
                              final item = _cartItem[index];
                              return CardProductCart(
                                item: item,
                                onIncrease: () {
                                  _updateItem(
                                    index,
                                    item.quantity + 1,
                                    item.note ?? "",
                                  );
                                },
                                onDecrease: () {
                                  _updateItem(
                                    index,
                                    item.quantity - 1,
                                    item.note ?? "",
                                  );
                                },
                              );
                            },
                          ),

                    const SizedBox(height: 30),
                    const Divider(thickness: 1),
                    const SizedBox(height: 20),

                    // --- Phần Tổng Tiền ---
                    _buildSummaryRow("Tổng Phụ", _subTotal),
                    const SizedBox(height: 10),
                    _buildSummaryRow(
                      "Khuyến Mãi",
                      discountAmount,
                      isDiscount: true,
                    ), // Hiển thị % hoặc số tiền giảm
                    const SizedBox(height: 10),
                    Divider(), // Khoảng trắng ảo hoặc kẻ ngang

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Tổng Cộng",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentFormat.format(finalTotal),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE95322),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // --- Nút Xác Nhận ---
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Xử lý sự kiện đặt hàng / thanh toán
                          print("Đã bấm xác nhận");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(
                            0xFFFFC529,
                          ), // Màu nền nút (màu da cam nhạt trong ảnh)
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          "Xác Nhận",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE95322), // Màu chữ
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget con để vẽ các dòng tổng tiền cho gọn code
  Widget _buildSummaryRow(
    String label,
    double amount, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        Text(
          isDiscount
              ? "30%"
              : currentFormat.format(
                  amount,
                ), // Nếu là khuyến mãi thì hiện 30% như ảnh
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
