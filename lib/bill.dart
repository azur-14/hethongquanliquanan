import 'package:flutter/material.dart';

class BillScreen extends StatelessWidget {
  final String tableName = 'Bàn 001';
  final List<Map<String, dynamic>> orderedItems = [
    {'name': 'Avocado and Egg Toast', 'qty': 2, 'price': 10.80, 'image': 'assets/food.jpg'},
    {'name': 'Curry Salmon', 'qty': 2, 'price': 9.60, 'image': 'assets/food.jpg'},
    {'name': 'Yogurt and Fruits', 'qty': 1, 'price': 6.00, 'image': 'assets/food.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    double subtotal = orderedItems.fold(
      0,
          (sum, item) => sum + (item['qty'] * item['price']),
    );
    double tax = 5.0;
    double total = subtotal + tax;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Row(
        children: [
          // Sidebar (tuỳ bạn tái sử dụng component)
          Container(
            width: 200,
            color: Color(0xFF2F2F3E),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("EatEasy", style: TextStyle(color: Colors.white, fontSize: 22)),
                SizedBox(height: 40),
                SidebarButton(icon: Icons.restaurant_menu, label: "MÓN ĂN", selected: false),
                SidebarButton(icon: Icons.list_alt, label: "ĐƠN MÓN", selected: false),
                SidebarButton(icon: Icons.receipt, label: "HÓA ĐƠN", selected: true),
                Spacer(),
                SidebarButton(icon: Icons.logout, label: "THOÁT", selected: false),
                SizedBox(height: 30),
              ],
            ),
          ),

          // Nội dung chính
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🧾 $tableName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),

                  // Danh sách món
                  ...orderedItems.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Image.asset(item['image'], width: 40, height: 40),
                        SizedBox(width: 15),
                        Expanded(child: Text(item['name'], style: TextStyle(fontSize: 16))),
                        Text('${item['qty']} × \$${item['price'].toStringAsFixed(2)}'),
                      ],
                    ),
                  )),

                  Divider(height: 40, thickness: 1.2),

                  // Tính tiền
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subtotal:', style: TextStyle(fontSize: 16)),
                      Text('\$${subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Tax:', style: TextStyle(fontSize: 16)),
                      Text('\$${tax.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Mã giảm giá
                  Text('Add discount code/tags', style: TextStyle(color: Colors.grey[600])),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Apply discount code',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(onPressed: () {}, child: Text("Apply"))
                    ],
                  ),

                  Spacer(),

                  // Total + Pay
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Total price", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("\$${total.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {},
                      child: Text("Pay \$${total.toStringAsFixed(2)}", style: TextStyle(fontSize: 18)),
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

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const SidebarButton({required this.icon, required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: selected
          ? BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10))
          : null,
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.white : Colors.white70),
        title: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.white70)),
        onTap: () {},
      ),
    );
  }
}
