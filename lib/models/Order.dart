import 'OrderItems.dart';

class Order {
  final String orderId;
  final int tableId;
  final String status;
  final String? note;
  final double total;
  final DateTime time;
  final List<OrderItems> details;

  Order({
    required this.orderId,
    required this.tableId,
    required this.status,
    required this.note,
    required this.total,
    required this.time,
    required this.details,
  });

  factory Order.fromJsonWithDetails(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      tableId: json['tableId'],
      status: json['status'],
      note: json['note'],
      total: (json['total'] as num).toDouble(),
      time: DateTime.parse(json['time']),
      details: (json['details'] as List<dynamic>)
          .map((item) => OrderItems.fromJson(item))
          .toList(),
    );
  }
}
