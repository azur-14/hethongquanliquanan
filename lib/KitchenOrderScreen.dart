import 'package:flutter/material.dart';

class KitchenOrderScreen extends StatelessWidget {
  final List<Map<String, dynamic>> orders = [
    {'table': 'Bàn 001', 'status': 'Chờ xác nhận', 'locked': false},
    {'table': 'Bàn 002', 'status': 'Chưa có đơn nào', 'locked': true},
    {'table': 'Bàn 003', 'status': 'Đơn được đặt', 'locked': false},
    {'table': 'Bàn 004', 'status': 'Đã giao món', 'locked': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
            width: 200,
            color: Color(0xFF2F2F3E),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("EatEasy", style: TextStyle(color: Colors.orange, fontSize: 22)),
                SizedBox(height: 40),
                SidebarButton(icon: Icons.restaurant_menu, label: "MÓN ĂN", selected: false),
                SidebarButton(icon: Icons.list_alt, label: "ĐƠN MÓN", selected: true),
                Spacer(),
                SidebarButton(icon: Icons.logout, label: "Thoát", selected: false),
                SizedBox(height: 30),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: GridView.builder(
                itemCount: orders.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 1.5,
                ),
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order['table'],
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 8),
                        Text(order['status']),
                        Spacer(),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Icon(
                            order['locked'] ? Icons.lock : Icons.lock_open,
                            color: order['locked'] ? Colors.grey : Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const SidebarButton({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: selected
          ? BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10))
          : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label, style: TextStyle(color: Colors.white)),
        onTap: () {},
      ),
    );
  }
}