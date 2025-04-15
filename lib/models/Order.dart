import 'OrderItems.dart';

class Order {
  final String orderId;
  final int tableId;
  final String status;
  final String? note;
  final double total;
  final DateTime timeCreated;
  final DateTime? timeEnd;
  final List<OrderItems> details;

  Order({
    required this.orderId,
    required this.tableId,
    required this.status,
    required this.note,
    required this.total,
    required this.timeCreated,
    this.timeEnd,
    required this.details,
  });

  factory Order.fromJsonWithDetails(Map<String, dynamic> json) {
    return Order(
      orderId: json['orderId'],
      tableId: json['tableId'],
      status: json['status'],
      note: json['note'],
      total: (json['total'] as num).toDouble(),
      timeCreated: DateTime.parse(json['timeCreated']),
      timeEnd: json['timeEnd'] != null ? DateTime.tryParse(json['timeEnd']) : null,
      details: (json['details'] as List<dynamic>)
          .map((item) => OrderItems.fromJson(item))
          .toList(),
    );
  }
}
