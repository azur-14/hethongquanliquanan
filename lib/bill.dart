import 'package:flutter/material.dart';
import 'package:soagiuakiquanan/pdfgenerator.dart';
import 'Sidebar.dart';
import 'models/Bill.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme/color.dart';
import 'pdfgenerator.dart';

class BillScreen extends StatefulWidget {
  final String billId;
  final String role;

  const BillScreen({Key? key, required this.billId, required this.role}) : super(key: key);

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  Bill? bill;

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    double subtotal = bill!.total;
    double tax = 5.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Sidebar(
            selectedItem: "Hóa đơn",
            onSelectItem: (_) {},
            role: widget.role,
            table: bill!.table,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: BillContent(
                bill: bill!,
                subtotal: subtotal,
                tax: tax,
                onComplete: () => setState(() {
                  setStateAndLoad(bill!.billId);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadBill(String status) async {
    final tableId = widget.billId.replaceAll(RegExp(r'\D'), '');
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
      }
    } catch (e) {
      print("Lỗi: $e");
    }
    return null;
  }

  Future<void> setStateOrder(String orderId) async {
    try {
      final uri = Uri.parse('http://localhost:3001/api/orders/$orderId/status');
      await http.put(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'status': "completed"}));
    } catch (e) {
      print("Lỗi cập nhật trạng thái: $e");
    }
  }

  Future<void> updateTableStatus(String tableName) async {
    final tableId = tableName.replaceAll(RegExp(r'\D'), '');
    try {
      final uri = Uri.parse('http://localhost:3003/api/table/$tableId');
      await http.patch(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'status': false}));
    } catch (e) {
      print("Lỗi cập nhật trạng thái bàn: $e");
    }
  }
}

class BillContent extends StatefulWidget {
  final Bill bill;
  final double subtotal;
  final double tax;
  final VoidCallback onComplete;

  const BillContent({
    required this.bill,
    required this.subtotal,
    required this.tax,
    required this.onComplete,
  });

  @override
  State<BillContent> createState() => _BillContentState();
}

class _BillContentState extends State<BillContent> {
  double discountPercent = 0;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.bill.status == 'completed';
    final discountAmount = widget.subtotal * discountPercent / 100;
    final total = widget.subtotal + widget.tax - discountAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🧾 Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('🧾 Hóa đơn - ${widget.bill.table}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Chip(
              label: Text(
                isCompleted ? 'Hoàn tất' : 'Đang chờ',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: isCompleted ? Colors.green : Colors.orange,
            ),
          ],
        ),
        const SizedBox(height: 20),

        // 📦 Danh sách món
        ...widget.bill.items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  item.image,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Image.asset('assets/food.jpg', width: 70, height: 70),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(item.name, style: const TextStyle(fontSize: 16))),
              Text('${item.qty} × \$${item.price.toStringAsFixed(2)}'),
            ],
          ),
        )),
        const Divider(height: 40, thickness: 1.2),

        // 💸 Thông tin giá
        buildRow('Tạm tính:', widget.subtotal),
        buildRow('Thuế:', widget.tax),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Giảm giá (%):', style: TextStyle(fontSize: 16)),
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
                decoration: const InputDecoration(hintText: "0", suffixText: "%"),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        buildRow('Tổng cộng:', total,
            isBold: true, color: AppColors.primary),

        const Spacer(),

        // 🔘 Nút hành động
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (!isCompleted)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle, color: AppColors.primaryDark),
                label: const Text("Hoàn thành đơn",
                    style: TextStyle(color: AppColors.dark)),
                onPressed: widget.onComplete,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.primaryDark),
                  ),
                  elevation: 2,
                ),
              ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.print, color: Colors.white),
              label: const Text("Xuất hóa đơn", style: TextStyle(color: Colors.white)),
              onPressed: () async {
                await generateAndSavePdf(widget.bill, widget.tax, discountPercent);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("✅ Đã lưu file PDF vào bộ nhớ.")),
                );
              },

              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 5,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildRow(String title, double amount,
      {bool isBold = false, Color color = AppColors.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text('\$${amount.toStringAsFixed(2)}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: color)),
        ],
      ),
    );
  }
}
