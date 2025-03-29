import 'package:flutter/material.dart';
import 'package:soagiuakiquanan/models/OrderItems.dart';
import 'Sidebar.dart';
import 'bill.dart';
import 'models/TableList.dart';
import 'models/OrderItemCard.dart';
import 'models/OrderItems.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderPage extends StatefulWidget {
  final String role;
  final String? table;

  const OrderPage({required this.role, this.table});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? selectedTable;
  List<TableList> tables = [];
  List<OrderItems> orderItems = [];
  String selectedSidebarItem = "Đơn món";

  @override
  void initState() {
    super.initState();
    fetchTableListAndItems();
  }

  Future<void> fetchTableListAndItems() async {
    await fetchTableList();
    await fetchOrderItemList();
  }


  @override
  Widget build(BuildContext context) {
    final allReady = orderItems.every((item) => item.status); // true nếu tất cả là "Lên món"
    double subtotal = orderItems.fold(
        0, (sum, item) => sum + (item.price));
    double tax = 5.00;
    double totalPrice = subtotal + tax;

    return Scaffold(
      drawer: MediaQuery.of(context).size.width < 800
          ? Sidebar(
        selectedItem: selectedSidebarItem,
        onSelectItem: (item) {
          setState(() {
            selectedSidebarItem = item;
          });
        },
        role: widget.role,
        table: selectedTable ?? '',
      )
          : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 800)
            Sidebar(
              selectedItem: selectedSidebarItem,
              onSelectItem: (item) {
                setState(() {
                  selectedSidebarItem = item;
                });
              },
              role: widget.role,
              table: selectedTable ?? '',
            ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.role == "Nhân viên phục vụ" ||
                      widget.role == "Quản lý")
                    DropdownButton<String>(
                      value: selectedTable,
                      items: tables
                          .where((table) => table.status) // 👉 chỉ lấy những bàn đã mở
                          .map((table) {
                        return DropdownMenuItem(
                          value: table.name,
                          child: Text(table.name , style: TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTable = value!;
                        });
                        fetchOrderItemList();
                      },
                    )
                  else
                    Text(selectedTable ?? '',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),

                  SizedBox(height: 10),

                  // 🔸 Danh sách món
                  Expanded(
                    child: ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        var item = orderItems[index];
                        return OrderItemCard(
                          name: item.name,
                          price: item.price,
                          image: item.image,
                          quantity: item.quantity,
                          status: item.status,
                        );
                      },
                    ),
                  ),

                  // 🔸 Xuất hóa đơn
                  if ((widget.role == "Nhân viên phục vụ" || widget.role == "Quản lý") && allReady)
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BillScreen(
                                billId: selectedTable!,
                                role: widget.role,
                              ),
                            ),
                          );
                        },
                        icon: Icon(Icons.receipt_long),
                        label: Text("Xuất hóa đơn"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 🔸 Sidebar đơn hàng
          if (MediaQuery.of(context).size.width >= 1100)
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Đơn của bạn",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Divider(),
                  ...orderItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
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
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: TextStyle(fontSize: 14,),
                                    maxLines: 2, // 👈 Cho phép xuống dòng
                                    overflow: TextOverflow.ellipsis, // 👈 Có thể giữ để tránh tràn layout
                                  ),
                                  Text(!item.status ? "Đang thực hiện" : "Lên món",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: item.status ? Colors.green : Colors.orange,
                                      )),
                                ],
                              ),
                            ],
                          ),
                          Text(
                              "x${item.quantity}  \$${item.price.toStringAsFixed(2)}",
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                    );
                  }).toList(),
                  Divider(),
                  Text("Subtotal:  \$${subtotal.toStringAsFixed(2)}"),
                  Text("Tax:       \$${tax.toStringAsFixed(2)}"),
                  SizedBox(height: 10),
                  Text("Total:     \$${totalPrice.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> fetchTableList() async {
    try {
      final uri = Uri.parse("http://localhost:3003/api/table");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final loadedTables = data.map((item) => TableList.fromJson(item)).toList();
        setState(() {
          tables = loadedTables;
          selectedTable = widget.table ??
              loadedTables.firstWhere((t) => t.status == true,
                  orElse: () => loadedTables.first)
                  .name;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách bàn: $e");
    }
  }

  Future<void> fetchOrderItemList() async {
    if (selectedTable == null) return;

    final tableId = selectedTable!.replaceAll(RegExp(r'\D'), ''); // "Bàn 001" -> "001"

    try {
      final uri = Uri.parse("http://localhost:3001/api/orderdetails/table/$tableId");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final loadItems = data.map((item) {
          return OrderItems.fromJson(item);
        }).toList();
        setState(() {
          orderItems = loadItems;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách chi tiết hóa đơn: $e");
    }
  }

}