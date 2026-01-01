import 'package:appfastfood/utils/storage_helper.dart';
import 'package:http/http.dart' as http;
import '../models/products.dart';
import 'dart:convert';
import 'dart:io';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8001'; // Ưu tiên dùng IP máy ảo mặc định

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/login'),
        headers: _headers,
        body: jsonEncode({'username': username, 'password': password}),
      );

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        final token = jsonResponse['token'];
        if (token != null) {
          await StorageHelper.saveToke(token);
          return jsonResponse;
        }
      }
      throw jsonResponse['message'] ?? 'Đăng nhập thất bại';
    } catch (e) {
      throw 'Lỗi kết nối: $e';
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products'), headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return (jsonResponse['data'] as List)
              .map((item) => Product.fromJson(item))
              .toList();
        }
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products/$id'), headers: _headers);

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['success'] == true) {
          return Product.fromJson(jsonResponse['data']);
        }
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}