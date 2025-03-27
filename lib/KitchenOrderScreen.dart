import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'package:intl/intl.dart';

class KitchenOrderScreen extends StatefulWidget {
  const KitchenOrderScreen({Key? key}) : super(key: key);

  @override
  _KitchenOrderScreenState createState() => _KitchenOrderScreenState();
}

class _KitchenOrderScreenState extends State<KitchenOrderScreen> {
  List<Map<String, dynamic>> orders = [
    {
      'table': 'Bàn 001',
      'status': 'Đang chuẩn bị',
      'locked': false,
      'orderTime': DateTime.now().subtract(Duration(minutes: 15)),
      'note': 'Khách yêu cầu ít hành, thêm tương ớt riêng',
      'items': [
        {'name': 'Phở bò', 'qty': 2, 'done': false},
        {'name': 'Cafe đá', 'qty': 1, 'done': false},
      ],
    },
    {
      'table': 'Bàn 002',
      'status': 'Hoàn tất',
      'locked': true,
      'orderTime': DateTime.now().subtract(Duration(minutes: 30)),
      'note': 'Thêm pate vào bánh mì',
      'items': [
        {'name': 'Bánh mì', 'qty': 1, 'done': true},
      ],
    },
  ];

  void _updateOrderStatus(Map<String, dynamic> order) {
    bool allDone = order['items'].every((item) => (item as Map)['done']);
    setState(() {
      order['status'] = allDone ? 'Hoàn tất' : 'Đang chuẩn bị';
    });
  }

  void _showOrderDetailDialog(Map<String, dynamic> order) {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text('Chi tiết ${order['table']}'),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    order['note'] != null && order['note'].toString().isNotEmpty
                        ? Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'Ghi chú đơn hàng: ${order['note']}',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueAccent),
                      ),
                    )
                        : SizedBox.shrink(),
                    Expanded(
                      child: ListView(
                        shrinkWrap: true,
                        children: order['items'].map<Widget>((item) {
                          return CheckboxListTile(
                            title: Text('${item['name']} (x${item['qty']})'),
                            value: item['done'],
                            onChanged: order['locked']
                                ? null
                                : (val) {
                              setStateDialog(() {
                                item['done'] = val!;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  child: Text('Đóng'),
                  onPressed: () {
                    Navigator.pop(context);
                    _updateOrderStatus(order);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleOrders = orders.where((order) =>
    order['status'] == 'Đang chuẩn bị' || order['status'] == 'Hoàn tất').toList();

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
                      itemCount: visibleOrders.length,
                      itemBuilder: (context, index) {
                        final order = visibleOrders[index];
                        Color statusColor = order['status'] == 'Đang chuẩn bị'
                            ? Colors.blue
                            : Colors.green;

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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(order['table'],
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Icon(
                                    order['locked']
                                        ? Icons.lock
                                        : Icons.lock_open,
                                    color: order['locked']
                                        ? Colors.grey
                                        : Colors.green,
                                  ),
                                ],
                              ),
                              Divider(),
                              Text(order['status'],
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
                                  Text(DateFormat('HH:mm dd/MM/yyyy')
                                      .format(order['orderTime']),
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.grey)),
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
}
