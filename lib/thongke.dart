import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'bill.dart';
import 'Sidebar.dart';
import 'models/Shift.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class BillStatisticsScreen extends StatefulWidget {
  const BillStatisticsScreen({Key? key}) : super(key: key);

  @override
  State<BillStatisticsScreen> createState() => _BillStatisticsScreenState();
}

enum FilterOption { shift, day, month, quarter, year }

class _BillStatisticsScreenState extends State<BillStatisticsScreen> {
  FilterOption selectedOption = FilterOption.day;
  List<Shift> allShifts = [];
  DateTime selectedDate = DateTime.now();
  int selectedShift = 1;
  // Thêm đoạn này vào State:
  int selectedQuarter = 1;
  int selectedYearForQuarter = DateTime.now().year;

// Hàm filteredBills sửa lại như sau:
  List<Map<String, dynamic>> get filteredBills {
    return allBills.where((bill) {
      final billDate = bill['time'] as DateTime;
      switch (selectedOption) {
        case FilterOption.shift:
          return billDate.year == selectedDate.year &&
              billDate.month == selectedDate.month &&
              billDate.day == selectedDate.day &&
              ((selectedShift == 1 && billDate.hour < 12) ||
                  (selectedShift == 2 && billDate.hour >= 12));
        case FilterOption.day:
          return billDate.year == selectedDate.year &&
              billDate.month == selectedDate.month &&
              billDate.day == selectedDate.day;
        case FilterOption.month:
          return billDate.year == selectedDate.year &&
              billDate.month == selectedDate.month;
        case FilterOption.quarter:
          int billQuarter = ((billDate.month - 1) ~/ 3) + 1;
          return billDate.year == selectedYearForQuarter &&
              billQuarter == selectedQuarter;
        case FilterOption.year:
          return billDate.year == selectedDate.year;
        default:
          return false;
      }
    }).toList();
  }


  List<Map<String, dynamic>> allBills = [];

  @override
  void initState() {
    super.initState();
    fetchCompletedBills();
    fetchShifts();
  }

  void _pickDate(BuildContext context) async {
    if (selectedOption == FilterOption.month) {
      final picked = await showMonthPicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() => selectedDate = picked);
      }
    } else if (selectedOption == FilterOption.year || selectedOption == FilterOption.quarter) {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
        initialEntryMode: DatePickerEntryMode.calendarOnly,
      );
      if (picked != null) {
        setState(() => selectedDate = DateTime(picked.year));
      }
    } else {
      final picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2023),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() => selectedDate = picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalRevenue = filteredBills.fold(0.0, (sum, bill) => sum + bill['total']);

    return Scaffold(
      body: Row(
        children: [
          Sidebar(selectedItem: "Hóa Đơn", role: "Quản lý", onSelectItem: (_) {}),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DropdownButton<FilterOption>(
                        value: selectedOption,
                        onChanged: (val) => setState(() => selectedOption = val!),
                        items: const [
                          DropdownMenuItem(value: FilterOption.shift, child: Text("Theo Ca")),
                          DropdownMenuItem(value: FilterOption.day, child: Text("Theo Ngày")),
                          DropdownMenuItem(value: FilterOption.month, child: Text("Theo Tháng")),
                          DropdownMenuItem(value: FilterOption.quarter, child: Text("Theo Quý")),
                          DropdownMenuItem(value: FilterOption.year, child: Text("Theo Năm")),
                        ],
                      ),
                      SizedBox(width: 20),

                      // Chọn Ca (khi chọn thống kê theo Ca)
                      if (selectedOption == FilterOption.shift)
                        DropdownButton<int>(
                          value: selectedShift,
                          items: [1, 2]
                              .map((e) => DropdownMenuItem(value: e, child: Text("Ca $e")))
                              .toList(),
                          onChanged: (val) => setState(() => selectedShift = val!),
                        ),

                      // Chọn Quý và Năm riêng biệt (khi chọn thống kê theo quý)
                      if (selectedOption == FilterOption.quarter) ...[
                        DropdownButton<int>(
                          value: selectedQuarter,
                          items: [1, 2, 3, 4]
                              .map((e) => DropdownMenuItem(value: e, child: Text("Quý $e")))
                              .toList(),
                          onChanged: (val) => setState(() => selectedQuarter = val!),
                        ),
                        SizedBox(width: 20),
                        DropdownButton<int>(
                          value: selectedYearForQuarter,
                          items: List.generate(10, (index) => 2023 + index)
                              .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
                              .toList(),
                          onChanged: (val) => setState(() => selectedYearForQuarter = val!),
                        ),
                      ],

                      // Các loại thống kê còn lại dùng DatePicker
                      if (selectedOption != FilterOption.quarter && selectedOption != FilterOption.shift)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                          onPressed: () => _pickDate(context),
                          child: Text(selectedOption == FilterOption.year
                              ? "Chọn năm: ${selectedDate.year}"
                              : selectedOption == FilterOption.month
                              ? DateFormat('MM/yyyy').format(selectedDate)
                              : DateFormat('dd/MM/yyyy').format(selectedDate)),
                        ),

                      if (selectedOption == FilterOption.shift)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.orangeAccent),
                          onPressed: () => _pickDate(context),
                          child: Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
                        ),
                    ],
                  ),
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
                  SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: filteredBills.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final bill = filteredBills[index];
                        final billTimeVN = (bill["time"] as DateTime);
                        final billTimeVNFormatted = DateFormat('dd/MM/yyyy - HH:mm').format(billTimeVN);

                        return FutureBuilder<String>(
                          future: fetchShiftFromApi(billTimeVN),
                          builder: (context, snapshot) {
                            final shiftName = snapshot.data ?? '...';
                            return ListTile(
                              tileColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              leading: Icon(Icons.receipt_long, color: Colors.orange),
                              title: Text("${bill['billId']} - Bàn ${bill['tableId']}"),
                              subtitle: Text("$billTimeVNFormatted ($shiftName)"),
                              trailing: Text("\$${bill['total'].toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BillScreen(
                                    billId: bill['billId'],
                                    role: 'Quản lý',
                                    checkDetails: true,
                                    tableId: bill['tableId'].toString(),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }
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

  Future<void> fetchCompletedBills() async {
    try {
      final uri = Uri.parse("http://localhost:3001/api/orders/completed"); // đổi nếu bạn dùng cổng khác
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);

        setState(() {
          allBills = data.map((order) {
            return {
              'billId': '${order["orderId"].toString().padLeft(3, '0')}',
              'tableId': order["tableId"],
              'status': order["status"],
              'note': order["note"] ?? '',
              'total': (order["total"] as num).toDouble(),
              'time': DateTime.parse(order["time"]), // đảm bảo `createdTime` là chuỗi ISO
            };
          }).toList();
        });
      } else {
        print("❌ Lỗi khi lấy hóa đơn: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi kết nối API hóa đơn: $e");
    }
  }

  Future<void> fetchShifts() async {
    try {
      final uri = Uri.parse("http://localhost:3002/api/shifts");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          allShifts = data.map((e) => Shift.fromJson(e)).toList();
        });
      } else {
        print("❌ Lỗi khi lấy ca làm việc: ${response.statusCode}");
      }
    } catch (e) {
      print("❌ Lỗi kết nối API shift: $e");
    }
  }

  Future<String> fetchShiftFromApi(DateTime billTimeVN) async {
    final formattedTime = billTimeVN.toUtc().toIso8601String(); // Gửi UTC lên server
    print(formattedTime);

    final uri = Uri.parse('http://localhost:3002/api/shifts/by-time?time=$formattedTime');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['shiftName'] ?? "Không rõ";
    } else {
      print("❌ Không thể lấy ca từ API: ${response.body}");
      return "Không rõ";
    }
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
