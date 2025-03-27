import 'package:flutter/material.dart';
import 'Sidebar.dart';

class BillScreen extends StatefulWidget {
  final String billId;
  final String role;  // Add role as a parameter

  const BillScreen({Key? key, required this.billId, required this.role}) : super(key: key);

  @override
  _BillScreenState createState() => _BillScreenState();
}

class _BillScreenState extends State<BillScreen> {
  List<Map<String, dynamic>> allBills = [
    {
      'billId': '#HD001',
      'table': 'Bàn 001',
      'status': 'pending',
      'items': [
        {'name': 'Avocado and Egg Toast', 'qty': 2, 'price': 10.80, 'image': 'assets/food.jpg'},
        {'name': 'Curry Salmon', 'qty': 2, 'price': 9.60, 'image': 'assets/food.jpg'},
        {'name': 'Yogurt and Fruits', 'qty': 1, 'price': 6.00, 'image': 'assets/food.jpg'},
      ]
    },
    {
      'billId': '#HD002',
      'table': 'Bàn 002',
      'status': 'completed',
      'items': [
        {'name': 'Mac and Cheese', 'qty': 1, 'price': 12.00, 'image': 'assets/food.jpg'},
        {'name': 'Orange Juice', 'qty': 2, 'price': 4.50, 'image': 'assets/food.jpg'},
      ]
    },
  ];

  Map<String, dynamic>? bill;

  @override
  void initState() {
    super.initState();
    bill = allBills.firstWhere((b) => b['billId'] == widget.billId, orElse: () => {});
  }

  @override
  Widget build(BuildContext context) {
    if (bill == null || bill!.isEmpty) {
      return Scaffold(
        body: Center(child: Text("❌ Không tìm thấy hóa đơn ${widget.billId}")),
      );
    }

    final String tableName = bill!['table'];
    final List<Map<String, dynamic>> orderedItems = List.from(bill!['items']);
    final String status = bill!['status'];

    double subtotal = orderedItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
    double tax = 5.0;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedItem: "Hóa đơn",
            onSelectItem: (_) {},
            role: widget.role, // Use role from the previous screen
            table: tableName,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: BillContent(
                billId: widget.billId,
                tableName: tableName,
                orderedItems: orderedItems,
                subtotal: subtotal,
                tax: tax,
                status: status,
                onComplete: () {
                  setState(() {
                    bill!['status'] = 'completed';
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class BillContent extends StatefulWidget {
  final String billId;
  final String tableName;
  final List<Map<String, dynamic>> orderedItems;
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
              Image.asset(item['image'], width: 40, height: 40),
              SizedBox(width: 15),
              Expanded(child: Text(item['name'], style: TextStyle(fontSize: 16))),
              Text('${item['qty']} × \$${item['price'].toStringAsFixed(2)}'),
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
