import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'OrderPage.dart';
import 'SidebarItem.dart';
import 'menu.dart';
class Sidebar extends StatelessWidget {
  final String selectedItem;
  final Function(String) onSelectItem;

  Sidebar({this.selectedItem = "Món ăn", required this.onSelectItem});

  void navigateToPage(BuildContext context, String title) {
    if (title == "Món ăn" && selectedItem != "Món ăn") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => EatEasyApp()));
    } else if (title =="Đơn món" && selectedItem != "Đơn món") {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => OrderPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Color(0xFF2E2E48),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("EatEasy",
              style: TextStyle(
                  color: Color(0xFFAB5C37),
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 40),

          SidebarItem(
              icon: Icons.restaurant_menu,
              title: "Món ăn",
              isSelected: selectedItem == "Món ăn",
              onTap: () => navigateToPage(context, "Món ăn")),

          SidebarItem(
              icon: Icons.shopping_cart,
              title: "Đơn món",
              isSelected: selectedItem == "Đơn món",
              onTap: () => navigateToPage(context, "Đơn món")),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: Colors.white54),
          ),

          SidebarItem(
              icon: Icons.exit_to_app,
              title: "Thoát",
              isSelected: false,
              onTap: () {}),
        ],
      ),
    );
  }
}
