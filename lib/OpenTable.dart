import 'package:flutter/material.dart';
import 'models/TableList.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
class OpenTableScreen extends StatefulWidget {
  const OpenTableScreen({Key? key}) : super(key: key);

  @override
  State<OpenTableScreen> createState() => _OpenTableScreenState();
}

class _OpenTableScreenState extends State<OpenTableScreen> {
  List<TableList> tables = [];

  @override
  void initState() {
    super.initState();
    fetchTableList();
  }

  void _returnOpenedTables() {
    List<TableList> opened = tables.where((t) => t.status == true).toList();
    Navigator.pop(context, opened); // ✅ truyền đúng kiểu List<TableList>
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sơ đồ bàn"),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _returnOpenedTables,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: tables.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (context, index) {
            final table = tables[index];
            return Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: table.status ? Colors.red[300] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_seat, size: 40, color: Colors.white),
                    SizedBox(height: 10),
                    Text(table.name, style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    if (!table.status)
                      ElevatedButton(
                        onPressed: () => _openTable(index),
                        child: Text("Mở bàn"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
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

  Future<void> _openTable(int index) async {
    final table = tables[index];
    final uri = Uri.parse("http://localhost:3003/api/table/${table.id}");

    try {
      final response = await http.patch(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"status": true}),
      );

      if (response.statusCode == 200) {
        setState(() {
          tables[index].status = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Đã mở ${table.name}"), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Không thể mở bàn: ${response.statusCode}"), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Lỗi mở bàn: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối khi mở bàn"), backgroundColor: Colors.red),
      );
    }
  }

}
