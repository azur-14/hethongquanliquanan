import 'package:flutter/material.dart';
class FoodItemCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final int quantity;
  final Function(int) onQuantityChanged;

  FoodItemCard({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(image, width: 60, height: 60, fit: BoxFit.cover),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  name,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  price,
                  style: TextStyle(color: Color(0xFFFF7B2C), fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(Icons.remove_circle, color: Colors.grey),
                onPressed: () {
                  if (quantity > 0) onQuantityChanged(quantity - 1);
                },
              ),
              Container(
                width: 30,
                alignment: Alignment.center,
                child: Text(
                  quantity.toString(),
                  style: TextStyle(fontSize: 16),
                ),
              ),
              IconButton(
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                icon: Icon(Icons.add_circle, color: Color(0xFFFF7B2C)),
                onPressed: () => onQuantityChanged(quantity + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
