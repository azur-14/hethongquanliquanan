import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bill.dart';
class BillStatisticsScreen extends StatefulWidget {
  const BillStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<BillStatisticsScreen> createState() => _BillStatisticsScreenState();
}

class _BillStatisticsScreenState extends State<BillStatisticsScreen> {
  DateTimeRange? selectedRange;
  final List<Map<String, dynamic>> allBills = [
    {'billId': '#HD001', 'table': 'Bàn 1', 'total': 50.0, 'date': DateTime(2025, 3, 10)},
    {'billId': '#HD002', 'table': 'Bàn 2', 'total': 80.0, 'date': DateTime(2025, 3, 15)},
    {'billId': '#HD003', 'table': 'Bàn 3', 'total': 60.0, 'date': DateTime(2025, 3, 20)},
    {'billId': '#HD004', 'table': 'Bàn 1', 'total': 40.0, 'date': DateTime(2025, 3, 25)},
  ];

  List<Map<String, dynamic>> get filteredBills {
    if (selectedRange == null) return allBills;
    return allBills.where((bill) {
      return bill['date'].isAfter(selectedRange!.start.subtract(Duration(days: 1))) &&
          bill['date'].isBefore(selectedRange!.end.add(Duration(days: 1)));
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedRange = DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalRevenue = filteredBills.fold(0.0, (sum, bill) => sum + bill['total']);
    final formatter = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: Color(0xFF2F2F3E),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("EatEasy", style: TextStyle(color: Colors.orange, fontSize: 22)),
                SizedBox(height: 40),
                SidebarButton(icon: Icons.restaurant_menu, label: "Món Ăn", selected: false),
                SidebarButton(icon: Icons.shopping_cart, label: "Đơn Món", selected: false),
                SidebarButton(icon: Icons.receipt_long, label: "Hóa Đơn", selected: true),
                Spacer(),
                SidebarButton(icon: Icons.logout, label: "Thoát", selected: false),
                SizedBox(height: 20),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Thống kê hóa đơn", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2023),
                            lastDate: DateTime(2100),
                            initialDateRange: selectedRange,
                          );
                          if (picked != null) {
                            setState(() {
                              selectedRange = picked;
                            });
                          }
                        },
                        icon: Icon(Icons.date_range),
                        label: Text(
                          selectedRange == null
                              ? "Chọn thời gian"
                              : "${formatter.format(selectedRange!.start)} - ${formatter.format(selectedRange!.end)}",
                        ),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Stats
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          title: "Số hóa đơn",
                          subtitle: "Tổng số hóa đơn",
                          value: filteredBills.length.toString(),
                          icon: Icons.receipt,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: StatCard(
                          title: "Doanh thu",
                          subtitle: "Tổng tiền thu",
                          value: "\$${totalRevenue.toStringAsFixed(2)}",
                          icon: Icons.attach_money,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  // Bill list
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredBills.length,
                      separatorBuilder: (_, __) => SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final bill = filteredBills[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BillScreen(billId: bill['billId']),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Thông tin bên trái
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Mã hóa đơn: ${bill['billId']}", style: TextStyle(fontWeight: FontWeight.bold)),
                                    Text("Bàn: ${bill['table']}"),
                                    Text("Ngày: ${DateFormat('dd/MM/yyyy').format(bill['date'])}"),
                                    Text("Ca: ${bill['shift']}"),
                                  ],
                                ),
                                // Tổng tiền
                                Text(
                                  "\$${bill['total'].toStringAsFixed(2)}",
                                  style: TextStyle(color: Colors.orange, fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const SidebarButton({required this.icon, required this.label, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: selected
          ? BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10))
          : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label, style: TextStyle(color: Colors.white)),
        onTap: () {},
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 36),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ],
      ),
    );
  }
}
