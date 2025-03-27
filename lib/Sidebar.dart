import 'package:flutter/material.dart';
import 'GeneralizeSecretCode.dart';
import 'KitchenMenuScreen.dart';
import 'KitchenOrderScreen.dart';
import 'Welcome.dart';
import 'OrderPage.dart';
import 'SidebarItem.dart';
import 'menu.dart';
import 'thongke.dart';

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
      } else {
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF2E2E48),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "EatEasy",
            style: TextStyle(
              color: Color(0xFFAB5C37),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),

          // Món ăn
          SidebarItem(
            icon: Icons.restaurant_menu,
            title: "Món ăn",
            isSelected: selectedItem == "Món ăn",
            onTap: () => navigateToPage(context, "Món ăn"),
          ),

          // Đơn món
          SidebarItem(
            icon: Icons.shopping_cart,
            title: "Đơn món",
            isSelected: selectedItem == "Đơn món",
            onTap: () => navigateToPage(context, "Đơn món"),
          ),

          // Thống kê (chỉ dành cho Quản lý)
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
              title: "Generate Code",
              isSelected: selectedItem == "Generate Code",
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const GenerateSecretCode()),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white54),
          ),

          // Thoát
          SidebarItem(
            icon: Icons.exit_to_app,
            title: "Thoát",
            isSelected: false,
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => WelcomeScreen()),
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
