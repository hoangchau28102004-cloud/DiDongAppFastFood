import 'package:flutter/material.dart';
import 'views/screens/home_screen.dart'; // Đảm bảo import đúng đường dẫn

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fast Food App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE95322)),
        useMaterial3: true,
      ),
      home: const HomePageScreen(),
    );
  }
}