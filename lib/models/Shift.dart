class Shift {
  final int shiftId;
  final String name;
  final String from;
  final String to;

  Shift({required this.shiftId, required this.name, required this.from, required this.to});

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      shiftId: json['shift_id'],
      name: json['name'],
      from: json['from'],
      to: json['to'],
    );
  }
}
