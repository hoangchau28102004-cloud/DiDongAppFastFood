import 'package:http/http.dart' as http;
import '../models/products.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8001';

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/products'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        if (jsonResponse['success'] == true) {
          List<dynamic> data = jsonResponse['data'];
          return data.map((item) => Product.fromJson(item)).toList();
        } else {
          throw Exception("API Error: ${jsonResponse['message']}");
        }
      } else {
        throw Exception("Server Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching products: $e");
      return []; // Trả về rỗng để UI không bị crash
    }
  }
}