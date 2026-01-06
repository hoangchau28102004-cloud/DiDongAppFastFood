import 'package:appfastfood/utils/app_colors.dart';
import 'package:appfastfood/views/screens/home_screen.dart';
import 'package:flutter/material.dart';

class TopBarPage extends StatelessWidget {
  final String title;
  final bool showBackButton;

  const TopBarPage({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFFFFC529),
      elevation: 0,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryOrange),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
      ),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const HomePageScreen()));
          },
          child: Icon(
            Icons.home_outlined,
            color: AppColors.primaryOrange,
          ),
        ),
      ],
      centerTitle: true,
    );
  }
}