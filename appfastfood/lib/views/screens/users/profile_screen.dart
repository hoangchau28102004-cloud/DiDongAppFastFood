import 'dart:io';
import 'package:appfastfood/models/user.dart';
import 'package:appfastfood/service/api_service.dart';
import 'package:appfastfood/utils/app_colors.dart';
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
  // Controller cho các ô nhập liệu
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();

  User? _currentUser;
  File? _selectedImage; // Ảnh chọn từ thư viện
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Lấy thông tin user từ API
  Future<void> _loadUserProfile() async {
    // Giả sử ApiService có hàm getProfile trả về User object
    // Nếu chưa có bạn dùng hàm userController.profile ở Backend để gọi
    // Ở đây mình giả định bạn đã có hàm lấy info, hoặc lấy tạm từ Storage
    
    // Gọi API lấy thông tin mới nhất
    try {
      final user = await ApiService().getProfile(); // Bạn cần đảm bảo hàm này có trong ApiService
      if (user != null) {
        setState(() {
          _currentUser = user;
          _nameController.text = user.fullname;
          _emailController.text = user.email;
          _phoneController.text = user.phone;
          
          // Xử lý ngày sinh
          if (user.birthday != null) {
            // Cắt chuỗi lấy yyyy-MM-dd nếu database trả về datetime dài
            String rawDate = user.birthday!; 
            if(rawDate.length >= 10) {
               _dobController.text = rawDate.substring(0, 10);
            } else {
               _dobController.text = rawDate;
            }
          }
        });
      }
    } catch (e) {
      print("Lỗi load profile: $e");
    } finally {
      setState(() => _isLoading = false);
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
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Vui lòng nhập họ tên")));
      return;
    }

    setState(() => _isLoading = true);

    bool success = await ApiService().updateProfile(
      _nameController.text,
      _emailController.text,
      _phoneController.text,
      _dobController.text,
      _selectedImage, // Truyền file ảnh (nếu có)
    );

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thành công!")));
      // Refresh lại data
      _loadUserProfile();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cập nhật thất bại. Kiểm tra lại Email/SĐT")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // 1. TopBar (Giữ nguyên của bạn)
          const TopBarPage(title: "Hồ Sơ Cá Nhân"),

          // 2. Nội dung chính
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // --- PHẦN AVATAR ---
                        Center(
                          child: Stack(
                            children: [
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 4,
                                      color: Theme.of(context).scaffoldBackgroundColor),
                                  boxShadow: [
                                    BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(0.1),
                                        offset: const Offset(0, 10))
                                  ],
                                  shape: BoxShape.circle,
                                ),
                                child: CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: _getAvatarImage(),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _pickImage,
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 4,
                                        color: Theme.of(context).scaffoldBackgroundColor,
                                      ),
                                      color: Colors.orange, // Màu chủ đạo của App
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 35),

                        // --- CÁC FORM NHẬP LIỆU ---
                        CustomTextField(
                            title: "Họ và tên",
                            controller: _nameController,
                            hintText: User != null ? _currentUser!.fullname : "",
                            suffixIcon: const Icon(Icons.person, color: AppColors.primaryOrange)),
                        const SizedBox(height: 20),
                        
                        CustomTextField(
                            title: "Email",
                            controller: _emailController,
                            hintText: User != null ? _currentUser!.email : "",
                            suffixIcon: const Icon(Icons.email, color: AppColors.primaryOrange),
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 20),
                        
                        CustomTextField(
                            title: "Số điện thoại",
                            controller: _phoneController,
                            hintText: User != null ? _currentUser!.phone : "",
                            suffixIcon: const Icon(Icons.phone, color: AppColors.primaryOrange),
                            keyboardType: TextInputType.phone),
                        const SizedBox(height: 20),
                        
                        // Ô chọn ngày sinh (Bấm vào hiện lịch)
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: AbsorbPointer(
                            child: CustomTextField(
                                title: "Ngày sinh",
                                controller: _dobController,
                                hintText: "Chọn ngày sinh",
                                suffixIcon: const Icon(Icons.calendar_today, color: AppColors.primaryOrange),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 40),

                        // --- CÁC NÚT  ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: const Text("Thay đổi địa chỉ",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                            ElevatedButton(
                              onPressed: _updateProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                              child: const Text("Cập nhật hồ sơ",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  // Widget hiển thị ảnh: Ưu tiên ảnh vừa chọn > Ảnh từ server > Ảnh mặc định
  ImageProvider _getAvatarImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    }
    if (_currentUser?.image != null && _currentUser!.image!.isNotEmpty) {
      // Đường dẫn ảnh server: http://IP:PORT/uploads/ten_anh.jpg
      // Cần đảm bảo ApiService.BaseUrl không có dấu / ở cuối hoặc xử lý nối chuỗi đúng
      return NetworkImage('${ApiService.BaseUrl}/${_currentUser!.image}');
    }
    return const AssetImage("assets/images/default_avatar.png"); // Nhớ có ảnh này trong assets
  }
}