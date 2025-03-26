import 'package:flutter/material.dart';
import 'Sidebar.dart';

class BillScreen extends StatelessWidget {
  final String billId;

  const BillScreen({Key? key, required this.billId}) : super(key: key);

  final List<Map<String, dynamic>> allBills = const [
    {
      'billId': '#HD001',
      'table': 'Bàn 001',
      'items': [
        {'name': 'Avocado and Egg Toast', 'qty': 2, 'price': 10.80, 'image': 'assets/food.jpg'},
        {'name': 'Curry Salmon', 'qty': 2, 'price': 9.60, 'image': 'assets/food.jpg'},
        {'name': 'Yogurt and Fruits', 'qty': 1, 'price': 6.00, 'image': 'assets/food.jpg'},
      ]
    },
    {
      'billId': '#HD002',
      'table': 'Bàn 002',
      'items': [
        {'name': 'Mac and Cheese', 'qty': 1, 'price': 12.00, 'image': 'assets/food.jpg'},
        {'name': 'Orange Juice', 'qty': 2, 'price': 4.50, 'image': 'assets/food.jpg'},
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
    final bill = allBills.firstWhere((b) => b['billId'] == billId, orElse: () => {});

    if (bill.isEmpty) {
      return Scaffold(
        body: Center(child: Text("❌ Không tìm thấy hóa đơn $billId")),
      );
    }

    final String tableName = bill['table'];
    final List<Map<String, dynamic>> orderedItems = List<Map<String, dynamic>>.from(bill['items']);
    double subtotal = orderedItems.fold(0, (sum, item) => sum + (item['qty'] * item['price']));
    double tax = 5.0;

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedItem: "Hóa đơn",
            onSelectItem: (_) {},
            role: "Quản lý",
            table: tableName,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: BillContent(
                billId: billId,
                tableName: tableName,
                orderedItems: orderedItems,
                subtotal: subtotal,
                tax: tax,
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

  const BillContent({
    required this.billId,
    required this.tableName,
    required this.orderedItems,
    required this.subtotal,
    required this.tax,
  });

  @override
  State<BillContent> createState() => _BillContentState();
}

class _BillContentState extends State<BillContent> {
  double discountPercent = 0;

  @override
  Widget build(BuildContext context) {
    double discountAmount = widget.subtotal * (discountPercent / 100);
    double total = widget.subtotal + widget.tax - discountAmount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('🧾 ${widget.tableName} - ${widget.billId}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal:', style: TextStyle(fontSize: 16)),
            Text('\$${widget.subtotal.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax:', style: TextStyle(fontSize: 16)),
            Text('\$${widget.tax.toStringAsFixed(2)}', style: TextStyle(fontSize: 16)),
          ],
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Giảm giá (%):', style: TextStyle(fontSize: 16)),
            Container(
              width: 80,
              child: TextField(
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total price", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("\$${total.toStringAsFixed(2)}",
                style: TextStyle(fontSize: 20, color: Colors.red, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {},
            child: Text("Xuất hóa đơn", style: TextStyle(fontSize: 18)),
          ),
        ),
      ],
    );
  }
}
