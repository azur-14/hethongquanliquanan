class Bill {
  final String billId;
  final String table;
  final String status;
  final double total;
  final List<BillItem> items;

  Bill({
    required this.billId,
    required this.table,
    required this.status,
    required this.total,
    required this.items,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      billId: json['orderId'] ?? '',
      table: 'Bàn ${json['tableId'].toString()}',
      status: json['status'] ?? 'pending',
      total: (json['total'] as num).toDouble(),
      items: (json['details'] as List<dynamic>).map((item) => BillItem.fromJson(item)).toList(),
    );
  }
}

class BillItem {
  final String name;
  final int qty;
  final double price;
  final String image;

  BillItem({
    required this.name,
    required this.qty,
    required this.price,
    required this.image,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      name: json['name'] ?? 'Unknown',
      qty: (json['quantity'] as num).toInt(),
      price: (json['price'] as num).toDouble(),
      image: json['image'] ?? 'assets/food.jpg',
    );
  }
}
