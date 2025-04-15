import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'GeneralizeSecretCode.dart';
import 'KitchenMenuScreen.dart';
import 'KitchenOrderScreen.dart';
import 'Welcome.dart';
import 'OrderPage.dart';
import 'SidebarItem.dart';
import 'menu.dart';
import 'thongke.dart';
import 'theme/color.dart';

class Sidebar extends StatelessWidget {
  final String selectedItem;
  final Function(String) onSelectItem;
  final String role;
  final String? table;

  const Sidebar({
    this.selectedItem = "Món ăn",
    required this.onSelectItem,
    required this.role,
    this.table,
  });

  void navigateToPage(BuildContext context, String title) {
    if (title == selectedItem) return;

    Widget targetPage;

    if (role == "Nhân viên bếp") {
      if (title == "Món ăn") {
        targetPage = KitchenMenuScreen();
      } else if (title == "Đơn món") {
        targetPage = KitchenOrderScreen();
      } else {
        return;
      }
    } else {
      if (title == "Món ăn") {
        targetPage = HomeScreen(role: role, table: table);
      } else if (title == "Đơn món") {
        targetPage = OrderPage(role: role, table: table);
      } else if (title == "Thống kê" && role == "Quản lý") {
        targetPage = BillStatisticsScreen();
      } else if (title == "Tạo mã bí mật" && role == "Quản lý") {
        targetPage = GenerateSecretCode();
      } else {
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );
  }

  void _confirmExit(BuildContext context) {
    if (role == "Khách hàng") {
      String inputCode = '';
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Nhập mã để thoát"),
            content: TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: "Nhập mã bí mật"),
              onChanged: (value) => inputCode = value,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Hủy"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final secret = await _fetchSecretCode();
                  if (inputCode == secret) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => WelcomeScreen()),
                          (route) => false,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Mã không đúng."),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
                child: Text("Xác nhận"),
              ),
            ],
          );
        },
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => WelcomeScreen()),
            (route) => false,
      );
    }
  }

  Future<String?> _fetchSecretCode() async {
    try {
      final uri = Uri.parse("http://localhost:3002/api/codes");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secretCode'];
      }
    } catch (e) {
      print("Lỗi lấy mã bí mật: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: AppColors.dark,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: RichText(
              text: TextSpan(
                text: 'Eat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                children: [
                  TextSpan(
                    text: 'Easy',
                    style: TextStyle(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SidebarItem(
            icon: Icons.restaurant_menu,
            title: "Món ăn",
            isSelected: selectedItem == "Món ăn",
            onTap: () => navigateToPage(context, "Món ăn"),
          ),
          SidebarItem(
            icon: Icons.shopping_cart,
            title: "Đơn món",
            isSelected: selectedItem == "Đơn món",
            onTap: () => navigateToPage(context, "Đơn món"),
          ),

          if (role == "Quản lý")
            SidebarItem(
              icon: Icons.bar_chart,
              title: "Thống kê",
              isSelected: selectedItem == "Thống kê",
              onTap: () => navigateToPage(context, "Thống kê"),
            ),

          if (role == "Quản lý")
            SidebarItem(
              icon: Icons.vpn_key,
              title: "Tạo mã bí mật",
              isSelected: selectedItem == "Tạo mã bí mật",
              onTap: () => navigateToPage(context, "Tạo mã bí mật"),
            ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white54),
          ),

          SidebarItem(
            icon: Icons.exit_to_app,
            title: "Thoát",
            isSelected: false,
            onTap: () => _confirmExit(context),
          ),
        ],
      ),
    );
  }
}
