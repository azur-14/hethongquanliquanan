import 'package:flutter/material.dart';

class FoodItemCard extends StatelessWidget {
  final String name;
  final String price;
  final String image;
  final String status;
  final int quantity;
  final Function(int) onQuantityChanged;

  FoodItemCard({
    required this.name,
    required this.price,
    required this.image,
    required this.status,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bool isInactive = status == 'inactive';

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: isInactive ? Colors.grey.shade300 : Colors.white, // 👉 Màu xám nếu inactive
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Hình ảnh món ăn
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: image.startsWith('http')
                ? Image.network(
              image,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/food.jpg', width: 70, height: 70, fit: BoxFit.cover);
              },
            )
                : Image.asset('assets/food.jpg', width: 70, height: 70, fit: BoxFit.cover),
          ),
          SizedBox(width: 10),

          // Thông tin món ăn + nút tăng giảm
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isInactive ? Colors.grey.shade600 : Colors.black, // 👉 text xám nếu inactive
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  price,
                  style: TextStyle(
                    color: isInactive ? Colors.grey : Color(0xFFFF7B2C),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(Icons.remove_circle, color: Colors.grey),
                      onPressed: isInactive || quantity <= 0
                          ? null
                          : () => onQuantityChanged(quantity - 1), // 👉 disabled if inactive
                    ),
                    SizedBox(width: 10),
                    Text(quantity.toString(), style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    IconButton(
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                      icon: Icon(Icons.add_circle, color: isInactive ? Colors.grey : Color(0xFFFF7B2C)),
                      onPressed: isInactive
                          ? null
                          : () => onQuantityChanged(quantity + 1), // 👉 disabled if inactive
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
