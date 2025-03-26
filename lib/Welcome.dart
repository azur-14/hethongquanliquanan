import 'package:flutter/material.dart';
import 'menu.dart';
import 'models/TableList.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? selectedRole;
  String? selectedTable;
  final List<String> roles = [
    'Quản lý',
    'Nhân viên phục vụ',
    'Khách hàng',
    'Nhân viên bếp',
  ];

  List<TableList> tables = [];

  @override
  void initState() {
    super.initState();
    fetchTableList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ảnh món ăn - góc trên trái
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/welcome_right.jpg',
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          // Ảnh món ăn - góc dưới phải
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/welcome_left.jpg',
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          // Nội dung chính
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'WELCOME BACK!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Ready to have a full digital experience in our restaurant',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 20),

                        // Chọn vai trò (thu gọn chiều rộng)
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: DropdownButtonFormField<String>(
                              value: selectedRole,
                              decoration: InputDecoration(
                                labelText: 'Chọn vai trò của bạn',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                              items: roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role,
                                  child: Text(role),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedRole = value;
                                  if (value != 'Khách hàng') {
                                    selectedTable = null;
                                  }
                                });
                              },
                            ),
                          ),
                        ),

                        // Nếu chọn Khách hàng thì hiện dropdown chọn bàn (cũng thu gọn)
                        if (selectedRole == 'Khách hàng') ...[
                          SizedBox(height: 16),
                          Center(
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: DropdownButtonFormField<String>(
                                value: selectedTable,
                                decoration: InputDecoration(
                                  labelText: 'Chọn bàn của bạn',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                ),
                                items: tables.map((table) {
                                  return DropdownMenuItem<String>(
                                    value: table.name,
                                    child: Text(table.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedTable = value;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],

                        SizedBox(height: 20),
                        // Nút Get Started (cũng thu gọn)
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.5,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                elevation: 5,
                                shadowColor: Colors.orangeAccent,
                              ),
                              onPressed: () async {
                                if (selectedRole == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Vui lòng chọn vai trò')),
                                  );
                                } else if (selectedRole == 'Khách hàng' && selectedTable == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Vui lòng chọn bàn cho khách hàng')),
                                  );
                                } else {
                                  String? createdOrderId;
                                  int? tableId;

                                  if (selectedRole == 'Khách hàng') {
                                    // 👉 Tìm bàn được chọn
                                    final selectedTableObject = tables.firstWhere(
                                          (table) => table.name == selectedTable,
                                      orElse: () => TableList(id: "", tableId: 0, name: 'Unknown', status: false),
                                    );
                                    tableId = selectedTableObject.tableId;

                                    // 👉 Tạo đơn hàng
                                    createdOrderId = await createOrder(tableId);
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => HomeScreen(
                                        role: selectedRole!,
                                        table: selectedRole == 'Khách hàng' ? selectedTable : null,
                                        tableId: tableId,
                                        orderId: createdOrderId,
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Get Started',
                                style: TextStyle(color: Colors.white, fontSize: 18),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 32, color: Colors.black87),
                            children: [
                              TextSpan(text: 'Eat', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: 'Easy',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Text(
                            'Are you tired of scrolling through menus and struggling to decide\n'
                                'what to order? Our new restaurant app has got you covered\n'
                                'with personalized recommendations from our digital assistant.',
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> createOrder(int tableId) async {
    final String orderId = "DH${DateTime.now().millisecondsSinceEpoch}";
    final String apiUrl = "http://localhost:3001/api/order/create";

    print("📝 orderId = $orderId");
    print("🪑 tableId = $tableId");

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode({
        "orderId": orderId,
        "tableId": tableId,
        "status": "pending",
        "note": "",
        "total": 0
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final createdOrderId = responseData['donHang']['orderId'];
      print("✅ Đơn hàng tạo thành công");
      return createdOrderId;
    } else {
      print("❌ Lỗi tạo đơn hàng: ${response.body}");
      return null;
    }
  }


  Future<void> fetchTableList() async {
    try {
      final uri = Uri.parse("http://localhost:3003/api/table");

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          tables = data.map((item) => TableList.fromJson(item)).toList();
        });
      } else {
        print("Lỗi khi lấy danh sách món ăn: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối đến server: $e");
    }
  }
}
