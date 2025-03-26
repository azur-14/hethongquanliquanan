import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'FoodDetailMenu.dart';

class OrderPage extends StatefulWidget {
  final String role;
  final String? table;

  const OrderPage({required this.role, this.table});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late String selectedTable;
  List<String> tables = ['Bàn 001', 'Bàn 002', 'Bàn 003', 'Bàn 004'];
  String selectedSidebarItem = "Đơn món";

  List<Map<String, dynamic>> orderSummary = [
    {"name": "Avocado and Egg Toast", "price": 10.00, "quantity": 2, "image": "assets/food.jpg", "status": "Chờ xử lý"},
    {"name": "Curry Salmon", "price": 10.00, "quantity": 2, "image": "assets/food.jpg", "status": "Chờ xử lý"},
    {"name": "Yogurt and fruits", "price": 5.00, "quantity": 1, "image": "assets/food.jpg", "status": "Chờ xử lý"},
  ];

  @override
  void initState() {
    super.initState();
    selectedTable = widget.table ?? tables.first;
  }

  void _openEditModal(BuildContext context, int index) {
    if (orderSummary[index]["status"] != "Chờ xử lý") return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return FoodDetailModal(
          name: orderSummary[index]["name"],
          price: orderSummary[index]["price"].toString(),
          image: orderSummary[index]["image"],
          quantity: orderSummary[index]["quantity"],
          onQuantityChanged: (newQuantity) {
            setState(() {
              orderSummary[index]["quantity"] = newQuantity;
            });
          },
        );
      },
    );
  }

  void _removeItem(int index) {
    if (orderSummary[index]["status"] != "Chờ xử lý") return;
    setState(() {
      orderSummary.removeAt(index);
    });
  }

  void _placeOrder() {
    setState(() {
      for (var item in orderSummary) {
        if (item['status'] == 'Chờ xử lý') {
          item['status'] = 'Đang thực hiện';
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Đã đặt món thành công!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = orderSummary.fold(0, (sum, item) => sum + (item["price"] * item["quantity"]));
    double tax = 5.00;
    double totalPrice = subtotal + tax;
    bool hasItemsToPlace = orderSummary.any((item) => item['status'] == 'Chờ xử lý');

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
                  // 🔸 Tên bàn
                  widget.role == "Nhân viên phục vụ" || widget.role == "Quản lý"

                      ? DropdownButton<String>(
                    value: selectedTable,
                    items: tables.map((table) {
                      return DropdownMenuItem(
                        value: table,
                        child: Text(table, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedTable = value!;
                      });
                    },
                  )
                      : Text(selectedTable, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

                  SizedBox(height: 10),

                  // 🔸 Danh sách món
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: orderSummary.asMap().entries.map((entry) {
                          int index = entry.key;
                          var item = entry.value;
                          return OrderItemCard(
                            name: item["name"],
                            price: item["price"],
                            image: item["image"],
                            quantity: item["quantity"],
                            status: item["status"],
                            onEdit: () => _openEditModal(context, index),
                            onDelete: () => _removeItem(index),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔸 Giỏ hàng bên phải
          if (MediaQuery.of(context).size.width >= 1100)
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Đơn của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Divider(),

                  // 🔹 Chi tiết đơn
                  Column(
                    children: orderSummary.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(item["image"], width: 40, height: 40),
                                SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item["name"], style: TextStyle(fontSize: 14)),
                                    Text(item["status"],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: item["status"] == "Đang thực hiện"
                                              ? Colors.orange
                                              : Colors.grey,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            Text("x${item["quantity"]}  \$${item["price"].toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                  Divider(),
                  Text("Subtotal:  \$${subtotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 14)),
                  Text("Tax:  \$${tax.toStringAsFixed(2)}", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 10),
                  Text("Total price:  \$${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),

                  Spacer(),

                  if (hasItemsToPlace)
                    ElevatedButton(
                      onPressed: _placeOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Đặt", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// 🔸 Widget hiển thị từng món
class OrderItemCard extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final int quantity;
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const OrderItemCard({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (status) {
      case "Đang thực hiện":
        return Colors.orange;
      case "Lên món":
        return Colors.green;
      case "Chờ xử lý":
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditable = status == "Chờ xử lý";

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: status == "Đang thực hiện" ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(image, width: 50, height: 50, fit: BoxFit.cover),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Số lượng: $quantity", style: TextStyle(fontSize: 14)),
                Text("Trạng thái: $status", style: TextStyle(fontSize: 14, color: _getStatusColor())),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: isEditable ? Colors.orange : Colors.grey),
            onPressed: isEditable ? onEdit : null,
          ),
          IconButton(
            icon: Icon(Icons.delete, color: isEditable ? Colors.red : Colors.grey),
            onPressed: isEditable ? onDelete : null,
          ),
        ],
      ),
    );
  }
}
