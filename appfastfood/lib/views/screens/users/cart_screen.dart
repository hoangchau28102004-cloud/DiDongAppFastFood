import 'package:appfastfood/models/cartItem.dart';
import 'package:appfastfood/service/api_service.dart';
import 'package:appfastfood/views/screens/home_screen.dart';
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
  double _totalAmout = 0.0;
  final currentFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');

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
      _totalAmout = temp;
    });
  }

  Future<void> _updateItem(int index, int newQuantity, String newNote) async {
    final item = _cartItem[index];
    if (newQuantity <= 0) {
      setState(() {
        _cartItem.removeAt(index);
        _calculateTotal();
      });
    } else {
      setState(() {
        item.quantity = newQuantity;
        item.note = newNote;
        _calculateTotal();
      });
    }
    await ApiService().updateCart(item.cartId, newQuantity, newNote);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFE95322);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFC529),
        centerTitle: true,
        title: const Text(
          "Giỏ Hàng",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios_new, size: 30, color: primaryColor),
        ),
      ),
    );
  }
}
