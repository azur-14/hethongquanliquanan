class OrderItems {
  final String id;
  final String foodId;
  final String name;
  final String image;
  final double price;
  final int quantity;
  bool status;

  OrderItems({
    required this.id,
    required this.foodId,
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.status
  });

  factory OrderItems.fromJson(Map<String, dynamic> json) {
    return OrderItems(
      id: json['_id'] ?? '',
      foodId: json['foodId'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? 'assets/food.jpg',
      price: (json['price'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      status: json['status'] ?? false,
    );
  }
}
