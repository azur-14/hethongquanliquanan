import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'BillContent.dart';
import 'PrintBill.dart';
import 'Sidebar.dart';
import 'models/Bill.dart';
import 'theme/color.dart';

class BillScreen extends StatefulWidget {
  final String billId;
  final String role;  // Add role as a parameter
  final bool checkDetails;
  final String tableId;

  const BillScreen({Key? key, required this.billId, required this.role, required this.checkDetails, required this.tableId}) : super(key: key);

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  Bill? bill;
  @override
  void initState() {
    super.initState();
    if (widget.checkDetails) {
      loadBill(orderId: widget.billId);
    } else {
      loadBill(status: "pending");
    }
  }

  Future<void> setStateAndLoad(String orderId) async {
    await setStateOrder(orderId);
    await updateTableStatus(widget.billId);
    await loadBill(status: "completed");
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
                onComplete: () async {
                  await setStateAndLoad(bill!.billId);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> loadBill({String? status, String? orderId}) async {
    final tableId = widget.tableId;

    final result = await fetchBillByTableId(
      tableId: tableId,
      status: status,
      orderId: orderId,
    );

    if (mounted) {
      setState(() {
        bill = result;
      });
    }
  }

  Future<Bill?> fetchBillByTableId({
    required String tableId,
    String? status,
    String? orderId,
  }) async {
    try {
      // ⚙️ Xây dựng query string động
      String queryParams = '';
      if (orderId != null) {
        queryParams = '?orderId=$orderId';
      } else if (status != null) {
        queryParams = '?status=$status';
      }

      final uri = Uri.parse("http://localhost:3001/api/orders/bill/$tableId$queryParams");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Bill.fromJson(data);
      } else if (response.statusCode == 404) {
        print("Không tìm thấy hóa đơn cho bàn $tableId");
        return null;
      } else {
        print("Lỗi server: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối đến API: $e");
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
        print('Cập nhật trạng thái thất bại');
      }
    } catch (e) {
      print('Lỗi kết nối khi cập nhật trạng thái: $e');
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
        print('Bàn đã được chuyển về trạng thái chưa sử dụng');
      } else {
        print('Không thể cập nhật trạng thái bàn: ${response.statusCode}');
      }
    } catch (e) {
      print('Lỗi kết nối khi cập nhật trạng thái bàn: $e');
    }
  }

}
