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
  double _subTotal = 0.0;
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

  double _calculateTotal() {
    double temp = 0;
    for (var item in _cartItem) {
      temp += item.price * item.quantity;
    }
    setState(() {
      _subTotal = temp;
    });
    return _subTotal;
  }

  Future<void> _deleteItem(int index) async {
    final item = _cartItem[index];
    bool success = await ApiService().removeCart(item.cartId);
    if (success) {
      setState(() {
        _cartItem.removeAt(index);
        _calculateTotal();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã xóa khỏi giỏ hàng")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Thực hiện đã bị lỗi")));
    }
  }

  Future<void> _updateItem(int index, int newQuantity, String newNote) async {
    final item = _cartItem[index];
    int oldQuantity = item.quantity;
    setState(() {
      item.quantity = newQuantity;
      _calculateTotal();
    });

    try {
      bool success = await ApiService().updateCart(
        item.cartId,
        newQuantity,
        newNote,
      );
      if (!success) {
        setState(() {
          item.quantity = oldQuantity;
          _calculateTotal();
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Lỗi kết nối, không cập nhật được giỏ hàng"),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        item.quantity = oldQuantity;
        _calculateTotal();
      });
      print("Lỗi update: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    double finalTotal = _calculateTotal();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC529),
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
                    Text(
                      "Bạn Có ${_cartItem.length} Món Ăn Trong Giỏ Hàng",
                      style: const TextStyle(
                        color: Color(0xFFE95322),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
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
                                    item.note ?? "Không ghi chú",
                                  );
                                },
                                onDecrease: () {
                                  if (item.quantity > 1) {
                                    _updateItem(
                                      index,
                                      item.quantity - 1,
                                      item.note ?? "Không ghi chú",
                                    );
                                  }
                                },
                                onDelete: () {
                                  _deleteItem(index);
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
                    _buildSummaryRow("Khuyến Mãi", 0, isDiscount: false),
                    const SizedBox(height: 10),
                    Divider(),

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
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC529),
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
          isDiscount ? "% khi chọn khuyến mãi" : currentFormat.format(amount),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
