import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'FoodDetailMenu.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String selectedSidebarItem = "Đơn món";

  List<Map<String, dynamic>> orderSummary = [
    {"name": "Avocado and Egg Toast", "price": 10.00, "quantity": 2, "image": "assets/food.jpg", "status": "Chờ xử lý"},
    {"name": "Curry Salmon", "price": 10.00, "quantity": 2, "image": "assets/food.jpg", "status": "Đang thực hiện"},
    {"name": "Yogurt and fruits", "price": 5.00, "quantity": 1, "image": "assets/food.jpg", "status": "Lên món"},
  ];

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

          // 🔹 Danh sách món ăn đã đặt
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Bàn 001", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

                  SizedBox(height: 10),

                  // 🔹 Danh sách món ăn trong đơn
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: orderSummary.asMap().entries.map((entry) {
                          int index = entry.key;
                          Map<String, dynamic> item = entry.value;
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

          // 🔹 **Giỏ hàng bên phải**
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

                  // 🔹 **Danh sách món ăn trong giỏ hàng**
                  Column(
                    children: orderSummary.map((item) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(item["image"], width: 40, height: 40, fit: BoxFit.cover),
                              SizedBox(width: 10),
                              Text(item["name"], style: TextStyle(fontSize: 14)),
                            ],
                          ),
                          Text("x${item["quantity"]}  \$${item["price"]}", style: TextStyle(fontSize: 14)),
                        ],
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

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Đặt thêm món", style: TextStyle(color: Colors.white, fontSize: 16)),
                        SizedBox(width: 5),
                        Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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

// 🔹 **Món ăn đã đặt**
class OrderItemCard extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final int quantity;
  final String status;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  OrderItemCard({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.status,
    required this.onEdit,
    required this.onDelete,
  });

  Color _getStatusColor() {
    if (status == "Đang thực hiện") return Colors.orange;
    if (status == "Lên món") return Colors.green;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    bool isEditable = status == "Chờ xử lý";

    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
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
          IconButton(icon: Icon(Icons.edit, color: isEditable ? Colors.orange : Colors.grey), onPressed: isEditable ? onEdit : null),
          IconButton(icon: Icon(Icons.delete, color: isEditable ? Colors.red : Colors.grey), onPressed: isEditable ? onDelete : null),
        ],
      ),
    );
  }
}
