import 'package:flutter/material.dart';
import 'package:soagiuakiquanan/models/OrderItems.dart';
import 'Sidebar.dart';
import 'models/Order.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class KitchenOrderScreen extends StatefulWidget {
  const KitchenOrderScreen({Key? key}) : super(key: key);

  @override
  _KitchenOrderScreenState createState() => _KitchenOrderScreenState();
}

class _KitchenOrderScreenState extends State<KitchenOrderScreen> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedItem: "Đơn món",
            role: "Nhân viên bếp",
            onSelectItem: (_) {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Danh sách Đơn món",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : 4,
                        childAspectRatio: 1.1,
                        crossAxisSpacing: 18,
                        mainAxisSpacing: 18,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final isCompleted = order.details.every((d) => d.status);
                        final statusText = isCompleted ? "Hoàn tất" : "Đang chuẩn bị";
                        final statusColor = isCompleted ? Colors.green : Colors.blue;

                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 3))
                            ],
                          ),
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bàn ${order.tableId}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                              Divider(),
                              Text(statusText,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: statusColor,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.access_time,
                                      size: 16, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(DateFormat('HH:mm dd/MM/yyyy').format(order.timeCreated),
                                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () => _showOrderDetailDialog(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orangeAccent,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text("Xem đơn",
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ],
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

  void _showOrderDetailDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Chi tiết ${order.tableId != null ? "Bàn ${order.tableId}" : ""}'),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (order.note != null && order.note!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Text(
                          'Ghi chú đơn hàng: ${order.note}',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: order.details.length,
                        itemBuilder: (context, index) {
                          final detail = order.details[index];
                          return CheckboxListTile(
                            title: Text('${detail.name} (x${detail.quantity.toInt()})'),
                            value: detail.status,
                            onChanged: (val) async {
                              setStateDialog(() {
                                detail.status = val!;
                              });

                              try {
                                final uri = Uri.parse('http://localhost:3001/api/orderdetails/${detail.id}/status');
                                final response = await http.put(
                                  uri,
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({'status': detail.status}),
                                );
                                if (response.statusCode != 200) {
                                  print('Cập nhật trạng thái thất bại');
                                }
                              } catch (e) {
                                print('Lỗi kết nối khi cập nhật trạng thái: $e');
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {}); // Cập nhật lại trạng thái bên ngoài dialog
                  },
                  child: Text('Đóng'),
                )
              ],
            );
          },
        );
      },
    );
  }

  Future<void> fetchOrders() async {
    try {
      final uri = Uri.parse("http://localhost:3001/api/orders/pending-with-details");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          orders = data.map((item) => Order.fromJsonWithDetails(item)).toList();
        });
      } else {
        print("Lỗi khi lấy đơn hàng: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
    }
  }
}
