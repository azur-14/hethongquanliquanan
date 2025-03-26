import 'package:flutter/material.dart';
import 'welcome.dart';
import 'menu.dart';
import 'bill.dart';
import 'KitchenMenuScreen.dart';
import 'KitchenOrderScreen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: WelcomeScreen(),// Đặt WelcomeScreen làm trang chính
    );
  }
}
