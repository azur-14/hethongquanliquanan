import 'package:flutter/material.dart';

class OrderItemCard extends StatelessWidget {
  final String name;
  final double price;
  final String image;
  final int quantity;
  bool status;

  OrderItemCard({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.status,
  });

  Color _getStatusColor() {
    if (status) {
      return Colors.green;
    }
    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final check = status ? "Lên món" : "Đang thực hiện";
    return Container(
      padding: EdgeInsets.all(15),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: !status ? Colors.orange.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              image ?? '',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/food.jpg', width: 80, height: 80, fit: BoxFit.cover);
              },
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Số lượng: $quantity", style: TextStyle(fontSize: 14)),
                Text("Trạng thái: $check", style: TextStyle(fontSize: 14, color: _getStatusColor())),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
