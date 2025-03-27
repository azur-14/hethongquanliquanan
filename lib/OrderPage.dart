import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'bill.dart'; // Assuming you have bill.dart page

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
    {"name": "Avocado and Egg Toast", "price": 10.00, "quantity": 2, "image": "assets/food.jpg", "status": "Đang thực hiện"},
    {"name": "Curry Salmon", "price": 10.00, "quantity": 1, "image": "assets/food.jpg", "status": "Lên món"},
  ];

  @override
  void initState() {
    super.initState();
    selectedTable = widget.table ?? tables.first;
  }

  @override
  Widget build(BuildContext context) {
    double subtotal = orderSummary.fold(0, (sum, item) => sum + (item["price"] * item["quantity"]));
    double tax = 5.00;
    double totalPrice = subtotal + tax;

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
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  // 🔸 Xuất hóa đơn (chỉ nhân viên)
                  if (widget.role == "Nhân viên phục vụ" || widget.role == "Quản lý")
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => BillScreen(billId: "#HD001", role: widget.role,)),
                          );
                        },
                        icon: Icon(Icons.receipt_long),
                        label: Text("Xuất hóa đơn"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 🔸 Sidebar đơn hàng
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
                  Divider(),
                  ...orderSummary.map((item) {
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
                                            : Colors.green,
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
                  Divider(),
                  Text("Subtotal:  \$${subtotal.toStringAsFixed(2)}", style: TextStyle(fontSize: 14)),
                  Text("Tax:  \$${tax.toStringAsFixed(2)}", style: TextStyle(fontSize: 14)),
                  SizedBox(height: 10),
                  Text("Total:  \$${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// 🔹 Widget hiển thị từng món
class OrderItemCard extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final int quantity;
  final String status;

  const OrderItemCard({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.status,
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
        ],
      ),
    );
  }
}
