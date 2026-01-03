import 'package:appfastfood/utils/storage_helper.dart';
import 'package:http/http.dart' as http;
import '../models/products.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.100.248:8001'; //máy thật
  static const String BaseUrl = 'http://10.0.2.2:8001'; // máy ảo

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/api/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 &&
          jsonResponse['success'] == true &&
          jsonResponse['token'] != null) {
        Map<String, dynamic> userdata = jsonResponse['user'];
        await StorageHelper.saveToke(jsonResponse['token']);
        await StorageHelper.saveFullname(userdata['fullname']);
        await StorageHelper.saveUserId(userdata['user_id']);
        await StorageHelper.saveImage(userdata['Image']);
        return jsonResponse;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

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
      //print("Error fetching products: $e");
      return []; // Trả về rỗng để UI không bị crash
    }
  }

  Future<Product?> getProductById(String id) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/api/products/$id'));

      if (res.statusCode == 200) {
        final Map<String, dynamic> jsonRes = jsonDecode(res.body);

        if (jsonRes['success']) {
          Map<String, dynamic> data = jsonRes['data'];
          return Product.fromJson(data);
        }
      }
    } catch (e) {
      throw "Error not found product $e";
    }
    return null;
  }

  Future<bool> addFavorites(int productId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        return false;
      }
      final url = Uri.parse('$baseUrl/api/favorites/add');
      final res = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId}),
      );
      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);
        if (jsonRes['success'] == true) {
          return true;
        }
      }
      return false;
    } catch (e) {
      print("Lỗi addFavorite $e");
      return false;
    }
  }

  Future<bool> checkFav(int productId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return false;
      final res = await http.get(
        Uri.parse('$baseUrl/api/favorites/check?product_id=$productId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);
        return jsonRes['isFavorited'] == true;
      }
      return false;
    } catch (e) {
      print('Lỗi check fav $e');
      return false;
    }
  }

  Future<bool> removeFavorite(int productId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return false;

      final res = await http.post(
        Uri.parse('$baseUrl/api/favorites/remove'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'product_id': productId}),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Lỗi removeFavoreites $e');
      return false;
    }
  }
}
