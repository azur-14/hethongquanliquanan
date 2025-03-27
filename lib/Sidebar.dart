import 'package:flutter/material.dart';
import 'KitchenMenuScreen.dart';
import 'KitchenOrderScreen.dart';
import 'Welcome.dart';
import 'OrderPage.dart';
import 'SidebarItem.dart';
import 'menu.dart';

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
      // Nhân viên bếp
      if (title == "Món ăn") {
        targetPage = KitchenMenuScreen();
      } else if (title == "Đơn món") {
        targetPage = KitchenOrderScreen();
      } else {
        return;
      }
    } else {
      // Các role khác
      if (title == "Món ăn") {
        targetPage = HomeScreen(role: role, table: table);
      } else if (title == "Đơn món") {
        targetPage = OrderPage(role: role, table: table);
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
