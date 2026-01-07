import 'dart:convert';
import 'dart:io';
import 'package:appfastfood/models/user.dart';
import 'package:appfastfood/service/api_service.dart';
import 'package:appfastfood/utils/app_colors.dart';
import 'package:appfastfood/utils/storage_helper.dart';
import 'package:appfastfood/views/widget/auth_widgets.dart';
import 'package:appfastfood/views/widget/topbar_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Cần thêm intl vào pubspec.yaml để format ngày
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  User? _currentUser;
  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Lấy thông tin user từ API
  Future<void> _loadUserProfile() async {
    String? token = await StorageHelper.getToken();

    if (token != null) {
      // Gọi API lấy thông tin mới nhất
      User? userFetchedFromApi = await ApiService().getProfile();
      
      if (mounted) {
          setState(() {
            _currentUser = userFetchedFromApi;

            _nameController.text = _currentUser?.fullname ?? "";
            _emailController.text = _currentUser?.email ?? "";
            _phoneController.text = _currentUser?.phone ?? "";
            _dobController.text = _currentUser!.birthday!;

            if (_currentUser?.birthday != null &&  _currentUser!.birthday != "null") {
               try {
                 DateTime date = DateTime.parse(_currentUser!.birthday!);
                 _dobController.text = DateFormat('yyyy-MM-dd').format(date);
               } catch (e) {
                 _dobController.text = _currentUser!.birthday!; // Nếu lỗi format thì hiện nguyên gốc
               }
            } else {
               _dobController.text = "";
            }
          });
        }
    }
  }

  // Chọn ảnh từ Gallery
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  // Chọn ngày sinh
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  // Hàm lưu thông tin
  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    
    // Gọi API update
    bool success = await ApiService().updateProfile(
      fullname: _nameController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      birthday: _dobController.text,
      imageFile: _selectedImage, // Truyền file gốc, ApiService sẽ gửi multipart
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thành công!")),
      );
      _loadUserProfile(); // Load lại để thấy ảnh mới từ DB trả về
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cập nhật thất bại!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const TopBarPage(
            showBackButton: true,
            title: "Hồ sơ của tôi",
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[200],
                      backgroundImage: _getAvatarImage(), // Hàm xử lý ảnh mới
                      child: _getAvatarImage() == null 
                          ? const Icon(Icons.camera_alt, size: 40, color: Colors.grey) 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _nameController,
                    title: "Họ Tên",
                    hintText: _currentUser?.fullname ?? "Nhập họ tên",
                  ),

                  CustomTextField(
                    controller: _dobController,
                    title: "Ngày sinh",
                    hintText: _currentUser?.birthday ?? "Nhập ngày sinh",
                    onTap: () => _selectDate(context),
                  ),

                  CustomTextField(
                    controller: _emailController,
                    title: "Email",
                    hintText: _currentUser?.email ?? "Nhập email",
                  ),

                  CustomTextField(
                    controller: _phoneController,
                    title: "Số Điện Thoại",
                    hintText: _currentUser?.phone ?? "Nhập số điện thoại",
                  ),

                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to address screen logic
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFFC529)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Thay đổi địa chỉ",
                        style: TextStyle(
                          color: Color(0xFFFFC529),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Nút Update Profile
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC529),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          "Cập nhật hồ sơ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                    ),
                  ),
                ],
              ),
            )
          )
        ],
      ),
    );
  }

  // Widget hiển thị ảnh: Ưu tiên ảnh vừa chọn > Ảnh từ server > Ảnh mặc định
  ImageProvider? _getAvatarImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }

    if (_currentUser?.image != null && _currentUser!.image!.isNotEmpty) {
      try {
        String imgString = _currentUser!.image!;

        if (imgString.startsWith('data:image')) {
          var parts = imgString.split(',');
          if (parts.length > 1) {
             return MemoryImage(base64Decode(parts[1]));
          }
        }

        if (imgString.startsWith('http')) {
          return NetworkImage(imgString);
        }
      } catch (e) {
        print("Lỗi parse ảnh: $e");
      }
    }
    return null; 
  }
}
