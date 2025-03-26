import 'package:flutter/material.dart';
import 'FoodDetailMenu.dart';
import 'FoodItemCard.dart';
import 'Sidebar.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  final String? table;

  const HomeScreen({Key? key, required this.role, this.table}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> foodItems = [
    {"name": "Avocado and Egg Toast", "price": "\$10.40", "image": "assets/food.jpg"},
    {"name": "Mac and Cheese", "price": "\$10.40", "image": "assets/food.jpg"},
    {"name": "Power Bowl", "price": "\$10.40", "image": "assets/food.jpg"},
    {"name": "Vegetable Salad", "price": "\$10.40", "image": "assets/food.jpg"},
    {"name": "Avocado Chicken Salad", "price": "\$10.40", "image": "assets/food.jpg"},
    {"name": "Chicken Breast", "price": "\$10.40", "image": "assets/food.jpg"},
  ];

  String searchQuery = "";
  late String selectedTable;

  String selectedFilter = "Tất cả";
  String selectedSidebarItem = "Món ăn";

  List<String> tables = ["Bàn 001", "Bàn 002", "Bàn 003", "Bàn 004"];
  List<String> filters = ["Tất cả", "Phổ biến nhất", "Món chay", "Đồ uống"];

  @override
  void initState() {
    super.initState();
    selectedTable = widget.table ?? tables.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 800
          ? Sidebar(
        selectedItem: selectedSidebarItem,
        onSelectItem: (item) {
          setState(() {
            selectedSidebarItem = item;
          });
        },
        role: widget.role,
        table: selectedTable,
      )
          : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 800)
            Sidebar(
              selectedItem: selectedSidebarItem,
              onSelectItem: (item) {
                setState(() {
                  selectedSidebarItem = item;
                });
              },
              role: widget.role,
              table: selectedTable,
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Bàn + tìm kiếm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      widget.role == "Nhân viên phục vụ" || widget.role == "Quản lý"

                          ? DropdownButton<String>(
                        value: selectedTable,
                        items: tables.map((table) {
                          return DropdownMenuItem(
                            value: table,
                            child: Text(
                              table,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTable = value!;
                          });
                        },
                      )
                          : Text(
                        selectedTable,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),

                      // 🔍 Tìm kiếm
                      Container(
                        width: 300,
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Tìm món ăn...",
                            prefixIcon: Icon(Icons.search),
                          ),
                          onChanged: (value) {
                            setState(() {
                              searchQuery = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 🔹 Bộ lọc
                  Row(
                    children: filters.map((filter) {
                      return Padding(
                        padding: EdgeInsets.only(right: 10),
                        child: FilterButton(
                          title: filter,
                          isSelected: selectedFilter == filter,
                          onTap: () {
                            setState(() {
                              selectedFilter = filter;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 20),

                  // 🔹 Danh sách món ăn
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 3 : 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 2.8,
                      ),
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        return FoodItemCard(
                          name: foodItems[index]["name"]!,
                          price: foodItems[index]["price"]!,
                          image: foodItems[index]["image"]!,
                          quantity: 0,
                          onQuantityChanged: (newQuantity) {},
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Filter Button
class FilterButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  FilterButton({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Color(0xFFFF7B2C) : Colors.grey.shade300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      onPressed: onTap,
      child: Text(title, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
    );
  }
}
