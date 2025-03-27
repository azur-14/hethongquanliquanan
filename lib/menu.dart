import 'package:flutter/material.dart';
import 'FoodItemCard.dart';
import 'Sidebar.dart';
import 'OpenTable.dart';
import 'FilterButton.dart';
import 'models/Food.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String role;
  final String? table;

  const HomeScreen({Key? key, required this.role, this.table}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Food> foodItems = [];
  List<Map<String, dynamic>> cart = [];
  String orderNote = "";
  String searchQuery = "";
  late String selectedTable;
  String selectedFilter = "Tất cả";
  String selectedSidebarItem = "Món ăn";
  List<String> tables = ["Bàn 001", "Bàn 002", "Bàn 003", "Bàn 004"];
  List<String> filters = ["Tất cả", "Phổ biến nhất", "Món chay", "Đồ uống"];

  bool isLocked = false;  // Track if the system is locked
  String currentRole = "";

  @override
  void initState() {
    super.initState();
    selectedTable = widget.table ?? tables.first;
    currentRole = widget.role;  // Get the initial role from the widget
    fetchFoodItems();
  }

  void _handleLockUnlock() {
    if (currentRole == "Nhân viên phục vụ") {
      // If role is "Nhân viên phục vụ", lock and switch to "Khách hàng"
      showDialog(
        context: context,
        builder: (context) {
          String inputCode = '';
          return AlertDialog(
            title: Text("Nhập mã khóa"),
            content: TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: "Nhập mã bí mật"),
              onChanged: (value) {
                inputCode = value;
              },
            ),
            actions: [
              TextButton(
                child: Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Xác nhận"),
                onPressed: () {
                  if (inputCode == "1234") { // Correct code to lock
                    setState(() {
                      isLocked = true;
                      currentRole = "Khách hàng"; // Switch role to "Khách hàng"
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Đã chuyển sang chế độ Khách hàng."),
                      backgroundColor: Colors.green,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Mã không đúng."),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
              ),
            ],
          );
        },
      );
    } else {
      // If role is "Khách hàng", unlock and switch back to "Nhân viên phục vụ"
      showDialog(
        context: context,
        builder: (context) {
          String inputCode = '';
          return AlertDialog(
            title: Text("Nhập mã mở khóa"),
            content: TextField(
              obscureText: true,
              decoration: InputDecoration(hintText: "Nhập mã bí mật"),
              onChanged: (value) {
                inputCode = value;
              },
            ),
            actions: [
              TextButton(
                child: Text("Hủy"),
                onPressed: () => Navigator.pop(context),
              ),
              ElevatedButton(
                child: Text("Xác nhận"),
                onPressed: () {
                  if (inputCode == "1234") { // Correct code to unlock
                    setState(() {
                      isLocked = false;
                      currentRole = "Nhân viên phục vụ"; // Switch back to "Nhân viên phục vụ"
                    });
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Đã chuyển sang chế độ Nhân viên phục vụ."),
                      backgroundColor: Colors.green,
                    ));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Mã không đúng."),
                      backgroundColor: Colors.red,
                    ));
                  }
                },
              ),
            ],
          );
        },
      );
    }
  }

  double get subtotal => cart.fold(0.0, (sum, item) => sum + item["price"] * item["quantity"]);

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
        role: currentRole,
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
              role: currentRole,
              table: selectedTable,
            ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 Header: Bàn + Khóa + Mở bàn + Tìm
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (currentRole == "Nhân viên phục vụ" || currentRole == "Quản lý")
                          ? DropdownButton<String>(
                        value: selectedTable,
                        items: tables.map((table) {
                          return DropdownMenuItem(
                            value: table,
                            child: Text(table, style: TextStyle(fontWeight: FontWeight.bold)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTable = value!;
                          });
                        },
                      )
                          : Text(selectedTable, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Row(
                        children: [
                          // Show "Khóa" button if the role is "Nhân viên phục vụ"
                          if (currentRole == "Nhân viên phục vụ")
                            ElevatedButton.icon(
                              onPressed: _handleLockUnlock,
                              icon: Icon(Icons.lock),
                              label: Text("Khóa"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepOrange,
                              ),
                            ),
                          // Show "Mở khóa" button if the role is "Khách hàng"
                          if (currentRole == "Khách hàng")
                            ElevatedButton.icon(
                              onPressed: _handleLockUnlock,
                              icon: Icon(Icons.lock_open),
                              label: Text("Mở khóa"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey,
                              ),
                            ),
                          SizedBox(width: 12),
                          if (currentRole == "Nhân viên phục vụ" || currentRole == "Quản lý")
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (_) => OpenTableScreen()));
                              },
                              icon: Icon(Icons.event_seat),
                              label: Text("Mở bàn"),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),
                        ],
                      ),
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
                        crossAxisCount: 2, // 👉 2 món mỗi hàng
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 3.2, // 👉 Giãn rộng để tên hiển thị thoải mái
                      ),
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        final food = foodItems[index];
                        final quantity = cart.firstWhere(
                              (c) => c["name"] == food.name,
                          orElse: () => {"quantity": 0},
                        )["quantity"];
                        return FoodItemCard(
                          name: food.name,
                          price: "\$${food.price.toStringAsFixed(2)}",
                          image: food.image ?? 'assets/food.jpg',
                          quantity: quantity,
                          onQuantityChanged: (newQuantity) =>
                              _updateCart(food.name, food.price, food.image ?? 'assets/food.jpg', newQuantity, food.id),
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

  void _updateCart(String name, double price, String image, int quantity, String foodId) {
    setState(() {
      final index = cart.indexWhere((item) => item["name"] == name);
      if (index >= 0) {
        if (quantity == 0) {
          cart.removeAt(index);
        } else {
          cart[index]["quantity"] = quantity;
        }
      } else {
        if (quantity > 0) {
          cart.add({
            "name": name,
            "price": price,
            "image": image,
            "quantity": quantity,
            "foodId": foodId, // 👈 Bổ sung foodId
          });
        }
      }
    });
  }

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

  Future<void> placeOrder() async {
    if (cart.isEmpty) return;

    final uri = Uri.parse("http://localhost:3001/api/orders/create");

    final orderPayload = {
      "tableId": selectedTable.replaceAll(RegExp(r"\D"), ""), // "Bàn 001" -> "001"
      "note": orderNote,
      "cart": cart.map((item) => {
        "foodId": item["foodId"],  // phải có field này trong cart
        "quantity": item["quantity"],
        "price": item["price"],
        "ne": "", // hoặc note riêng từng món nếu có
      }).toList()
    };

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(orderPayload),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Đặt món thành công."),
        backgroundColor: Colors.green,
      ));
      setState(() {
        cart.clear();
        orderNote = "";
      });
    } else {
      print("❌ Đặt món thất bại: ${response.body}");
    }
  }
}
