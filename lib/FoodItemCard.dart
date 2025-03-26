import 'package:flutter/material.dart';
import 'FoodDetailMenu.dart';


class FoodItemCard extends StatelessWidget {
  final String id;
  final String name;
  final String price;
  final String image;
  final int quantity;
  final String description;
  final String? orderId;
  final Function(int) onQuantityChanged;

  FoodItemCard({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.description,
    this.orderId,
    required this.onQuantityChanged,
  });

  void _showFoodDetail(BuildContext context) {
    Navigator.push(
      context,
      PageRouteBuilder(
        opaque: false, // Keeps background visible
        pageBuilder: (context, animation, secondaryAnimation) {
          return FoodDetailModal(
            name: name,
            price: price,
            image: image,
            quantity: quantity,
            description: description,
            orderId: orderId,
            foodId: id,
            onQuantityChanged: onQuantityChanged,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Start from right
          const end = Offset.zero; // Move to center
          const curve = Curves.easeInOut;

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: image != null && image.startsWith('http')
                ? Image.network(
                  image ?? '',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset('assets/food.jpg', fit: BoxFit.cover);
                  },
                )
                : Image.asset('assets/food.jpg', fit: BoxFit.cover)

          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: Text(name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                Expanded(child: Text(price, style: TextStyle(color: Color(0xFFFF7B2C), fontSize: 18, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: Color(0xFFFF7B2C)),
            onPressed: () => _showFoodDetail(context),
          ),
        ],
      ),
    );
  }
}
