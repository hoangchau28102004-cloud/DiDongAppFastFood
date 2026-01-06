import 'dart:io';

import 'package:appfastfood/models/user.dart';

import 'package:appfastfood/models/cartItem.dart';
import 'package:appfastfood/utils/storage_helper.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import '../models/products.dart';
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8001'; //máy thật
  static const String BaseUrl = 'http://10.0.2.2:8001'; // máy ảo

  static final String urlEdit = baseUrl; //chỉnh url trên đây thôi

  // Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final url = Uri.parse('$urlEdit/api/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200 &&
          jsonResponse['success'] == true &&
          jsonResponse['token'] != null) {
        await StorageHelper.saveToke(jsonResponse['token']);
        await StorageHelper.saveUserId(jsonResponse['user']['user_id']);
        return jsonResponse;
      } else {
        throw Exception(jsonResponse['message'] ?? 'Đăng nhập thất bại');
      }
    } catch (e) {
      throw Exception('Lỗi đăng nhập: $e');
    }
  }

  // Đăng ký tài khoản
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

  // Lấy thông tin profile
  Future<User?> getProfile() async {
    try {
      final token = await StorageHelper.getToken();

      final url = Uri.parse('$urlEdit/users/profile');
      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['user'] != null) {
          return User.fromJson(data['user']);
        }
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  // Cập nhật thông tin profile
  Future<bool> updateProfile(
    String fullname,
    String email,
    String phone,
    String birthday,
    File? imageFile,
  ) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return false;

      var uri = Uri.parse('$urlEdit/api/users/profile/update');
      var request = http.MultipartRequest('POST', uri);

      request.headers.addAll({'Authorization': 'Bearer $token'});

      // Thêm các fields text
      request.fields['fullname'] = fullname;
      request.fields['email'] = email;
      request.fields['phone'] = phone;
      request.fields['birthday'] = birthday;

      // Thêm file ảnh
      if (imageFile != null) {
        var stream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'image',
          stream,
          length,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }

      // Gửi request
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(respStr);

        if (jsonResponse['success'] == true) {
          var updatedUser = User.fromJson(jsonResponse['user']);
          await StorageHelper.saveFullname(updatedUser.fullname);
          await StorageHelper.saveImage(updatedUser.image);
          return true;
        }
      } else {
        final respStr = await response.stream.bytesToString();
        print("Lỗi update: $respStr");
      }
      return false;
    } catch (e) {
      print("Lỗi Exception Update: $e");
      return false;
    }
  }

  // Gửi OTP
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

  // Đặt lại mật khẩu
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

  // Lấy tất cả sản phẩm
  Future<List<Product>> getAllProducts() async {
    try {
      final response = await http.get(Uri.parse('$urlEdit/api/products'));

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

  // Lấy chi tiết sản phẩm theo ID
  Future<Product?> getProductById(int id) async {
    try {
      final res = await http.get(Uri.parse('$urlEdit/api/products/$id'));

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

  // Favorite APIs
  Future<bool> addFavorites(int productId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) {
        return false;
      }
      final url = Uri.parse('$urlEdit/api/favorites/add');
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

  // Kiểm tra favorite
  Future<bool> checkFav(int productId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return false;
      final res = await http.get(
        Uri.parse('$urlEdit/api/favorites/check?product_id=$productId'),
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

  // Xóa favorite
  Future<bool> removeFavorite(int productId) async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return false;

      final res = await http.post(
        Uri.parse('$urlEdit/api/favorites/remove'),
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

  // Lấy danh sách sản phẩm yêu thích
  Future<List<Product>> getFavoriteList() async {
    try {
      final token = await StorageHelper.getToken();
      if (token == null) return [];

      final res = await http.get(
        Uri.parse('$urlEdit/api/favorites/list'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final jsonRes = jsonDecode(res.body);
        if (jsonRes['success'] == true) {
          List<dynamic> data = jsonRes['data'];
          return data.map((item) => Product.fromJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print('Lỗi getFavoriteList: $e');
      return [];
    }
  }

  Future<List<CartItem>> getCartList() async {
    final token = await StorageHelper.getToken();
    final res = await http.get(
      Uri.parse('$baseUrl/api/carts'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode == 200) {
      final jRes = jsonDecode(res.body);
      if (jRes['success']) {
        return (jRes['data'] as List)
            .map((items) => CartItem.fromJson(items))
            .toList();
      }
    }
    return [];
  }

  Future<bool> addToCart(int productId, int quantity, String note) async {
    final token = await StorageHelper.getToken();
    final res = await http.post(
      Uri.parse('$baseUrl/api/carts/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'product_id': productId,
        'quantity': quantity,
        'note': note,
      }),
    );
    return res.statusCode == 200;
  }

  Future<bool> updateCart(int cartId, int quantity, String note) async {
    final token = await StorageHelper.getToken();
    final res = await http.put(
      Uri.parse('$baseUrl/api/cart/update'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'cart_id': cartId, 'quantity': quantity, 'note': note}),
    );
    return res.statusCode == 200;
  }
}
