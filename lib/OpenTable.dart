import 'package:flutter/material.dart';

class OpenTableScreen extends StatefulWidget {
  const OpenTableScreen({Key? key}) : super(key: key);

  @override
  State<OpenTableScreen> createState() => _OpenTableScreenState();
}

class _OpenTableScreenState extends State<OpenTableScreen> {
  late List<Map<String, dynamic>> tables;

  @override
  void initState() {
    super.initState();
    tables = List.generate(
      12,
          (index) => {
        'name': 'Bàn ${index + 1}',
        'occupied': index % 3 == 0, // ví dụ: 1/3 bàn có người
      },
    );
  }

  void _openTable(int index) {
    setState(() {
      tables[index]['occupied'] = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${tables[index]['name']} đã được mở!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _returnOpenedTables() {
    List<String> opened = tables
        .where((t) => t['occupied'] == true)
        .map<String>((t) => t['name'] as String)
        .toList();
    Navigator.pop(context, opened);
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
                color: table['occupied'] ? Colors.red[300] : Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.event_seat, size: 40, color: Colors.white),
                    SizedBox(height: 10),
                    Text(table['name'], style: TextStyle(color: Colors.white)),
                    SizedBox(height: 10),
                    if (!table['occupied'])
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
}
