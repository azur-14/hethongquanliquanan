import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'models/Bill.dart';
import 'package:intl/intl.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class BillScreen extends StatefulWidget {
  final String billId;
  final String role;  // Add role as a parameter

  const BillScreen({Key? key, required this.billId, required this.role}) : super(key: key);

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  Bill? bill;

  @override

  @override
  void initState() {
    super.initState();
    loadBill("pending");
  }

  Future<void> setStateAndLoad(String orderId) async {
    await setStateOrder(orderId);
    await updateTableStatus(widget.billId);
    await loadBill("completed");
  }

  @override
  Widget build(BuildContext context) {
    if (bill == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double subtotal = bill!.total;
    double tax = 5.0;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedItem: "Hóa đơn",
            onSelectItem: (_) {},
            role: widget.role, // Use role from the previous screen
            table: bill!.table,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: BillContent(
                billId: widget.billId,
                tableName: "Hóa đơn",
                orderedItems: bill!.items,
                subtotal: subtotal,
                tax: tax,
                status: bill!.status,
                onComplete: () {
                  setState(() {
                    setStateAndLoad(bill!.billId);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadBill(String status) async {
    final tableId = widget.billId.replaceAll(RegExp(r'\D'), ''); // "Bàn 001" → "001"
    final result = await fetchBillByTableId(tableId, status);
    if (mounted) {
      setState(() {
        bill = result;
      });
    }
  }

  Future<Bill?> fetchBillByTableId(String tableId, String status) async {
    try {
      final uri = Uri.parse("http://localhost:3001/api/orders/bill/$tableId?status=$status");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Bill.fromJson(data);
      } else if (response.statusCode == 404) {
        print("Không tìm thấy hóa đơn cho bàn $tableId");
        return null;
      } else {
        print("❌ Lỗi server: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("❌ Lỗi kết nối đến API: $e");
      return null;
    }
  }

  Future<void> setStateOrder(String orderId) async {
    try {
      final uri = Uri.parse('http://localhost:3001/api/orders/$orderId/status');
      final response = await http.put(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': "completed"}),
      );
      if (response.statusCode != 200) {
        print('❌ Cập nhật trạng thái thất bại');
      }
    } catch (e) {
      print('❌ Lỗi kết nối khi cập nhật trạng thái: $e');
    }
  }

  Future<void> updateTableStatus(String tableName) async {
    final tableId = tableName.replaceAll(RegExp(r'\D'), ''); // "Bàn 001" → "001"
    try {
      final uri = Uri.parse('http://localhost:3003/api/table/$tableId');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': false}),
      );

      if (response.statusCode == 200) {
        print('✅ Bàn đã được chuyển về trạng thái chưa sử dụng');
      } else {
        print('❌ Không thể cập nhật trạng thái bàn: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Lỗi kết nối khi cập nhật trạng thái bàn: $e');
    }
  }

}


class BillContent extends StatefulWidget {
  final String billId;
  final String tableName;
  final List<BillItem> orderedItems;
  final double subtotal;
  final double tax;
  final String status;
  final VoidCallback onComplete;

  const BillContent({
    required this.billId,
    required this.tableName,
    required this.orderedItems,
    required this.subtotal,
    required this.tax,
    required this.status,
    required this.onComplete,
  });

  @override
  State<BillContent> createState() => _BillContentState();
}

class _BillContentState extends State<BillContent> {
  double discountPercent = 0;

  @override
  Widget build(BuildContext context) {
    bool isCompleted = widget.status == 'completed';

    double discountAmount = widget.subtotal * (discountPercent / 100);
    double total = widget.subtotal + widget.tax - discountAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('🧾 ${widget.tableName} - ${widget.billId}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Chip(
              label: Text(
                isCompleted ? 'Completed' : 'Pending',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: isCompleted ? Colors.green : Colors.orange,
            ),
          ],
        ),
        SizedBox(height: 20),
        ...widget.orderedItems.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Image.network(
                item.image ?? '',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset('assets/food.jpg', width: 80, height: 80, fit: BoxFit.cover);
                },
              ),
              SizedBox(width: 15),
              Expanded(child: Text(item.name, style: TextStyle(fontSize: 16))),
              Text('${item.qty} × \$${item.price.toStringAsFixed(2)}'),
            ],
          ),
        )),
        Divider(height: 40, thickness: 1.2),
        buildRow('Subtotal:', widget.subtotal),
        buildRow('Tax:', widget.tax),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Giảm giá (%):', style: TextStyle(fontSize: 16)),
            SizedBox(
              width: 80,
              child: TextField(
                enabled: !isCompleted,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    discountPercent = double.tryParse(value) ?? 0;
                  });
                },
                decoration: InputDecoration(hintText: "0", suffixText: "%"),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        buildRow('Total price:', total, isBold: true, color: Colors.red),
        SizedBox(height: 20),
        if (!isCompleted)
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: widget.onComplete,
              child: Text("Hoàn thành đơn", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () {},
            child: Text("Xuất hóa đơn", style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }

  Widget buildRow(String title, double amount, {bool isBold = false, Color color = Colors.black}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('\$${amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 16, color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
