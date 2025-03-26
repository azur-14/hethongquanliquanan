class Food {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? image;
  final String categoryName;

  Food({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.image,
    required this.categoryName,
  });

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      image: json['image'],
      categoryName: json['categoryName'] ?? 'Không rõ',
    );
  }
}
