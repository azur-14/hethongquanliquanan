import 'package:flutter/material.dart';
import 'FoodItemCard.dart';
import 'Sidebar.dart';
import 'OpenTable.dart';
import 'FilterButton.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  final String? table;

  const HomeScreen({Key? key, required this.role, this.table}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> foodItems = [
    {"name": "Avocado and Egg Toast", "price": 10.4, "image": "assets/food.jpg"},
    {"name": "Mac and Cheese", "price": 10.4, "image": "assets/food.jpg"},
    {"name": "Power Bowl", "price": 10.4, "image": "assets/food.jpg"},
    {"name": "Vegetable Salad", "price": 10.4, "image": "assets/food.jpg"},
    {"name": "Avocado Chicken Salad", "price": 10.4, "image": "assets/food.jpg"},
    {"name": "Chicken Breast", "price": 10.4, "image": "assets/food.jpg"},
  ];

  List<Map<String, dynamic>> cart = [];
  String orderNote = "";

  String searchQuery = "";
  late String selectedTable;
  String selectedFilter = "Tất cả";
  String selectedSidebarItem = "Món ăn";

  List<String> tables = ["Bàn 001", "Bàn 002", "Bàn 003", "Bàn 004"];
  List<String> filters = ["Tất cả", "Phổ biến nhất", "Món chay", "Đồ uống"];

  bool isLocked = false;
  String currentRole = "";

  @override
  void initState() {
    super.initState();
    selectedTable = widget.table ?? tables.first;
    currentRole = widget.role;
  }

  void _handleLockUnlock() {
    if (!isLocked) {
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
                  if (inputCode == "1234") {
                    setState(() {
                      isLocked = true;
                      currentRole = "Khách hàng";
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
      setState(() {
        isLocked = false;
        currentRole = "Nhân viên phục vụ";
      });
    }
  }

  void _updateCart(String name, double price, String image, int quantity) {
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
          cart.add({"name": name, "price": price, "image": image, "quantity": quantity});
        }
      }
    });
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
                          ElevatedButton.icon(
                            onPressed: _handleLockUnlock,
                            icon: Icon(isLocked ? Icons.lock_open : Icons.lock),
                            label: Text(isLocked ? "Mở khóa" : "Khóa"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isLocked ? Colors.grey : Colors.deepOrange,
                            ),
                          ),
                          SizedBox(width: 12),
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
                          onTap: () => setState(() => selectedFilter = filter),
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
                        childAspectRatio: MediaQuery.of(context).size.width > 1200 ? 3.5 : 3,
                      ),
                      itemCount: foodItems.length,
                      itemBuilder: (context, index) {
                        final item = foodItems[index];
                        final quantity = cart.firstWhere(
                              (c) => c["name"] == item["name"],
                          orElse: () => {"quantity": 0},
                        )["quantity"];
                        return FoodItemCard(
                          name: item["name"],
                          price: "\$${item["price"].toStringAsFixed(2)}",
                          image: item["image"],
                          quantity: quantity,
                          onQuantityChanged: (newQuantity) =>
                              _updateCart(item["name"], item["price"], item["image"], newQuantity),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 🔹 Sidebar giỏ hàng
          if (MediaQuery.of(context).size.width > 1100)
            Container(
              width: 320,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.grey.shade100, border: Border(left: BorderSide(color: Colors.grey))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Giỏ hàng", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  Expanded(
                    child: cart.isEmpty
                        ? Center(child: Text("Chưa có món nào được thêm."))
                        : ListView(
                      children: cart.map((item) {
                        return ListTile(
                          leading: Image.asset(item["image"], width: 40, height: 40, fit: BoxFit.cover),
                          title: Text(item["name"], style: TextStyle(fontSize: 14)),
                          subtitle: Text("x${item["quantity"]}"),
                          trailing: Text("\$${(item["price"] * item["quantity"]).toStringAsFixed(2)}"),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: "Thêm ghi chú cho đơn hàng...",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onChanged: (value) => orderNote = value,
                  ),
                  SizedBox(height: 10),
                  Text("Tổng cộng: \$${subtotal.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (cart.isEmpty) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("Đã đặt ${cart.length} món thành công."),
                        backgroundColor: Colors.green,
                      ));
                      setState(() {
                        cart.clear();
                        orderNote = "";
                      });
                    },
                    icon: Icon(Icons.check_circle),
                    label: Text("Đặt món"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
