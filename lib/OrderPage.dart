// ✅ Import & định nghĩa như cũ
import 'package:flutter/material.dart';
import 'package:soagiuakiquanan/models/OrderItems.dart';
import 'Sidebar.dart';
import 'bill.dart';
import 'models/TableList.dart';
import 'models/OrderItemCard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme/color.dart';

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
    final allReady = orderItems.every((item) => item.status);
    double subtotal = orderItems.fold(0, (sum, item) => sum + item.price);
    double tax = 5.00;
    double totalPrice = subtotal + tax;

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: MediaQuery.of(context).size.width < 800
          ? Sidebar(
        selectedItem: selectedSidebarItem,
        onSelectItem: (item) => setState(() => selectedSidebarItem = item),
        role: widget.role,
        table: selectedTable ?? '',
      )
          : null,
      body: Row(
        children: [
          if (MediaQuery.of(context).size.width >= 800)
            Sidebar(
              selectedItem: selectedSidebarItem,
              onSelectItem: (item) => setState(() => selectedSidebarItem = item),
              role: widget.role,
              table: selectedTable ?? '',
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.role == "Nhân viên phục vụ" || widget.role == "Quản lý")
                    DropdownButton<String>(
                      value: selectedTable,
                      items: tables
                          .where((table) => table.status)
                          .map((table) => DropdownMenuItem(
                        value: table.name,
                        child: Text(table.name, style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.text)),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedTable = value!;
                        });
                        fetchOrderItemList();
                      },
                    )
                  else
                    Text(selectedTable ?? '', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  SizedBox(height: 16),

                  // Danh sách đơn món
                  Expanded(
                    child: orderItems.isEmpty
                        ? Center(child: Text("Chưa có món nào.", style: TextStyle(color: AppColors.textSecondary)))
                        : ListView.builder(
                      itemCount: orderItems.length,
                      itemBuilder: (context, index) {
                        final item = orderItems[index];
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

                  // Nút xuất hóa đơn
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
                        icon: Icon(Icons.receipt_long, color: Colors.white),
                        label: Text("Xuất hóa đơn", style: TextStyle(color: Colors.white)),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>(
                                (states) => states.contains(MaterialState.pressed)
                                ? AppColors.primaryDark
                                : AppColors.primary,
                          ),
                          overlayColor: MaterialStateProperty.all(Colors.white.withOpacity(0.08)),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
                          elevation: MaterialStateProperty.all(4),
                          shadowColor: MaterialStateProperty.all(AppColors.primary.withOpacity(0.3)),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Sidebar đơn món
          if (MediaQuery.of(context).size.width >= 1100)
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, // hoặc Color(0xFFFFFCF9) cho tone nhẹ hơn
                border: Border(left: BorderSide(color: AppColors.border)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    offset: Offset(-2, 0),
                    blurRadius: 6,
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Đơn của bạn", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.text)),
                  Divider(),
                  ...orderItems.map((item) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  item.image ?? '',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Image.asset('assets/food.jpg', width: 70, height: 70, fit: BoxFit.cover),
                                ),
                              ),
                              SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 130,
                                    child: Text(
                                      item.name,
                                      style: TextStyle(fontSize: 14, color: AppColors.text),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    item.status ? "Lên món" : "Đang thực hiện",
                                    style: TextStyle(fontSize: 12, color: item.status ? Colors.green : Colors.orange),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            "x${item.quantity}  \$${item.price.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 14, color: AppColors.text),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  Divider(),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tạm tính:", style: TextStyle(color: AppColors.text)),
                      Text("\$${subtotal.toStringAsFixed(2)}", style: TextStyle(color: AppColors.text)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Thuế:", style: TextStyle(color: AppColors.text)),
                      Text("\$${tax.toStringAsFixed(2)}", style: TextStyle(color: AppColors.text)),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Tổng cộng:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        "\$${totalPrice.toStringAsFixed(2)}",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                      ),
                    ],
                  ),
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
          selectedTable = widget.table ?? loadedTables.firstWhere((t) => t.status, orElse: () => loadedTables.first).name;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách bàn: $e");
    }
  }

  Future<void> fetchOrderItemList() async {
    if (selectedTable == null) return;
    final tableId = selectedTable!.replaceAll(RegExp(r'\D'), '');
    try {
      final uri = Uri.parse("http://localhost:3001/api/orderdetails/table/$tableId");
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        final loadItems = data.map((item) => OrderItems.fromJson(item)).toList();
        setState(() {
          orderItems = loadItems;
        });
      }
    } catch (e) {
      print("Lỗi khi lấy danh sách chi tiết hóa đơn: $e");
    }
  }
}
