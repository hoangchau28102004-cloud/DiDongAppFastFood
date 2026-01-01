import 'dart:convert';
import 'package:appfastfood/service/api_service.dart';
import 'package:appfastfood/views/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  Future<void> _register() async {
    if (_usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _fullnameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng điền đầy đủ thông tin')),
      );
      return;
    }

    setState(() { _isLoading = true;});

    try {
      final response = await _apiService.register(
        _usernameController.text,
        _passwordController.text,
        _fullnameController.text,
        _emailController.text,
        _phoneController.text,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký thành công! Vui lòng đăng nhập.')),);
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> const LoginScreen()), (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Đăng ký thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi đăng ký: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color yellowHeader = Color(0xFFFCD057);
    const Color inputBg = Color(0xFFFEF5D3);
    const Color primaryOrange = Color(0xFFE95322);
    const Color textDark = Color(0xFF4A3B2C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              height: 150,
              decoration: const BoxDecoration(
                color: yellowHeader,
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Positioned(
                      left: 10,
                      top: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //Body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //INPUT FIELDS AND BUTTON
                  const Text("Username", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      hintText: 'Nhập Username',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text("Password", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      hintText: 'Nhập password',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: primaryOrange,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text("Full Name", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _fullnameController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      hintText: 'Nhập họ và tên',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text("Mobile Number", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      hintText: 'Nhập số điện thoại',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text("Email", style: TextStyle(fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    inputFormatters: [
                      FilteringTextInputFormatter.deny(RegExp(r'\s')), 
                    ],
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      hintText: 'Nhập email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const Center(child: Text("By continuing, you agree to",style: TextStyle(fontSize: 12, color: Colors.grey))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _showPolicyDialog(context, "Terms of Use", "Here are the Terms of Use...");
                        },
                        child: const Text(" Terms of Use ",style: TextStyle(fontSize: 12, color: primaryOrange)
                        ),
                      ),
                      const Text("and",style: TextStyle(fontSize: 12, color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          _showPolicyDialog(context, "Privacy Policy", "Nội dung chi tiết của Chính sách bảo mật.");
                        },
                        child: const Text(" Privacy Policy.",style: TextStyle(fontSize: 12, color: primaryOrange)
                        ),
                      ),
                    ],
                  ),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 3,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "Đăng Ký",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Center(child: Text("or sign up with", style: TextStyle(color: Colors.grey))),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton("assets/google_Icon.jpg", Colors.white),
                      const SizedBox(width: 10),
                      _buildSocialButton("assets/facebook_Icon.jpg", Colors.white),
                    ],
                  ),

                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
                      GestureDetector(
                        onTap: () {
                          // Điều hướng sang màn hình Đăng nhập
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginScreen()));
                        },
                        child: const Text(
                          "Log in",
                          style: TextStyle(color: primaryOrange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSocialButton(String assetName, Color bgColor) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Padding(padding: EdgeInsets.all(5), child: Image.asset(assetName,fit: BoxFit.contain)),
    );
  }

  // Hàm hiển thị hộp thoại chính sách
  void _showPolicyDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            height: 400,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
                // const Divider(),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}