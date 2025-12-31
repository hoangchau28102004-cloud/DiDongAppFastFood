import 'package:http/http.dart' as http;
import '../models/products.dart';
import 'dart:convert';

class ApiService {
  static const baseUrl = 'http://10.0.2.2:8001/api';

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/products'));

      if (response.statusCode == 200) {
        // 1. Decode JSON
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // 2. Kiểm tra success (theo mẫu JSON Postman của bạn)
        if (jsonResponse['success'] == true) {
          // 3. Lấy mảng 'data'
          List<dynamic> data = jsonResponse['data'];

          // 4. Map từng phần tử trong 'data' sang Product
          return data.map((item) => Product.fromJson(item)).toList();
        } else {
          throw Exception("API trả về lỗi: ${jsonResponse['message']}");
        }
      } else {
        throw Exception("Lỗi kết nối server: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
      return [];
    }
  }
}
