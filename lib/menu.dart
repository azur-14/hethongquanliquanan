import 'package:flutter/material.dart';
import 'FoodDetailMenu.dart';
import 'FoodItemCard.dart';
import 'Sidebar.dart';
import 'models/Food.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class EatEasyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EatEasy',
      theme: ThemeData(primaryColor: Colors.orange),
      home: HomeScreen(role: 'Khách hàng', table: 'Bàn 001'), // test thử vai trò ở đây
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String role;
  final String? table;
  final String? orderId;
  final int? tableId;

  const HomeScreen({Key? key, required this.role, this.table, this.orderId, this.tableId}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late String? currentOrderId;
  List<Food> foodItems = [];

  String searchQuery = "";
  late String selectedTable;

  String selectedFilter = "Tất cả";
  String selectedSidebarItem = "Món ăn";

  List<String> tables = ["Bàn 001", "Bàn 002", "Bàn 003", "Bàn 004"];
  List<String> filters = ["Tất cả", "Phổ biến nhất", "Món chay", "Đồ uống"];

  Future<void> fetchFoodItems() async {
    try {
      final uri = Uri.parse("http://localhost:3001/api/foods?search=$searchQuery&categoryName=${selectedFilter == 'Tất cả' ? '' : selectedFilter}");

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          foodItems = data.map((item) => Food.fromJson(item)).toList();
        });
      } else {
        print("Lỗi khi lấy danh sách món ăn: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối đến server: $e");
    }
  }


  @override
  void initState() {
    super.initState();
    selectedTable = widget.table ?? "Bàn 001";
    currentOrderId = widget.orderId;
    fetchFoodItems();
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
                      widget.role == "Nhân viên phục vụ"
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

                      // 🔎 Ô tìm kiếm
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
                            fetchFoodItems();
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // 🔹 Bộ lọc món ăn
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
                            fetchFoodItems();
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
                        final food = foodItems[index];
                        return FoodItemCard(
                          id: food.id,
                          name: food.name,
                          price: "\$${food.price.toStringAsFixed(2)}",
                          image: food.image ?? 'assets/food.jpg',
                          quantity: 0,
                          description: food.description ?? "",
                          orderId: currentOrderId,
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


 