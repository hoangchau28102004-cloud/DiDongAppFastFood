import 'package:appfastfood/utils/storage_helper.dart';
import 'package:http/http.dart' as http;
import '../models/products.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://192.168.1.15:8001'; //máy thật
  static const String BaseUrl = 'http://127.0.0.1:8001'; // máy ảo

  static final String urlEdit = BaseUrl; //chỉnh url trên đây thôi

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$BaseUrl/api/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password,
    String fullname,
    String email,
    String phone,
  ) async {
    try {
      final url = Uri.parse('$urlEdit/api/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'fullname': fullname,
          'email': email,
          'phone': phone,
        }),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          jsonResponse['success'] == true) {
        return jsonResponse;
      } else {
        throw Exception(
          jsonResponse['message'] ?? 'Đăng ký thất bại (Lỗi không xác định)',
        );
      }
    } catch (e) {
      throw Exception('Lỗi đăng ký: $e');
    }
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final url = Uri.parse('$urlEdit/api/send-otp');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Gửi OTP thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi gửi OTP: $e');
    }
  }

  Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final url = Uri.parse('$urlEdit/api/reset-password');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
        }),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonResponse['success'] == true) {
        return jsonResponse;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Đặt lại mật khẩu thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi đặt lại mật khẩu: $e');
    }
  }

  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$BaseUrl/api/products'));

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
      final res = await http.get(Uri.parse('$BaseUrl/api/products/$id'));

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
