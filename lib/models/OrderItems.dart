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
    final foodData = json['foodId'];

    return OrderItems(
      id: json['_id'] ?? '',
      foodId: foodData is Map ? (foodData['_id'] ?? '') : (foodData ?? ''),
      name: json['name'] ?? (foodData is Map ? foodData['name'] ?? '' : ''),
      image: json['image'] ?? (foodData is Map ? foodData['image'] ?? 'assets/food.jpg' : 'assets/food.jpg'),
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toInt(),
      status: json['status'] ?? false,
    );
  }

}
