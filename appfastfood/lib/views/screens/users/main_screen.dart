import 'package:flutter/material.dart';
import '../../widget/custom_bottom_bar.dart';
import '../../widget/side_menu.dart'; // Import SideMenu để dùng chung cho các màn hình nếu cần
import 'home_screen.dart';
import 'promotion_screen.dart';
import 'favorite_screen.dart';
import 'history_screen.dart';
import 'support_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Danh sách các màn hình tương ứng với 5 tab
  final List<Widget> _pages = [
    const HomePageScreen(), // Index 0
    const PromotionScreen(), // Index 1
    const FavoriteScreen(), // Index 2
    const HistoryScreen(), // Index 3
    const SupportScreen(), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Drawer (Menu bên phải) có thể để ở đây để dùng chung cho toàn app
      endDrawer: const SideMenu(),

      // Body thay đổi nội dung mà không load lại Scaffold
      body: _pages[_currentIndex],

      // Thanh Bottom Bar nằm cố định ở đây
      bottomNavigationBar: CustomBottomBar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
