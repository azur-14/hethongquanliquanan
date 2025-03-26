class TableList {
  final String id;
  final int tableId;
  final String name;
  final bool status;

  TableList({
    required this.id,
    required this.tableId,
    required this.name,
    required this.status
  });

  factory TableList.fromJson(Map<String, dynamic> json) {
    return TableList(
      id: json['_id'] ?? '',
      tableId: (json['table_id'] as num).toInt(),
      name: json['table_name'] ?? '',
      status: json['status'] ?? false,
    );
  }
}
