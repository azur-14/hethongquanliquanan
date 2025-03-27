class Food {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? image;
  final String categoryName;
  String status;

  Food({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.image,
    required this.categoryName,
    required this.status,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      image: json['image'],
      categoryName: json['categoryName'] ?? 'Không rõ',
      status: json['status'] ?? "inactive",
    );
  }
}
