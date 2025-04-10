import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:soagiuakiquanan/theme/color.dart';

import 'PrintBill.dart';
import 'models/Bill.dart';

class BillContent extends StatefulWidget {
  final String billId;
  final String tableName;
  final List<BillItem> orderedItems;
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

  final currencyFormatter = NumberFormat.decimalPattern('vi');

  @override
  Widget build(BuildContext context) {
    bool isCompleted = widget.status == 'completed';

    double discountAmount = widget.subtotal * (discountPercent / 100);
    double tax = widget.subtotal * 0.10;
    double total = widget.subtotal + tax - discountAmount;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🧾 Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                    tooltip: 'Quay lại',
                  ),
                  Text(
                    '🧾 ${widget.tableName} - ${widget.billId}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Chip(
                label: Text(
                  isCompleted ? 'Hoàn tất' : 'Đang chờ',
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: isCompleted ? Colors.green : Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 📦 Danh sách món
          ...widget.orderedItems.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    item.image,
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Image.asset(
                      'assets/food.jpg',
                      width: 70,
                      height: 70,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(item.name, style: const TextStyle(fontSize: 16)),
                ),
                Text('${item.qty} × ${currencyFormatter.format(item.price)} đồng'),

              ],
            ),
          )),
          const Divider(height: 40, thickness: 1.2),

          // 💸 Thông tin giá
          buildRow('Tạm tính:', widget.subtotal),
          buildRow('Thuế:', tax),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Giảm giá (%):', style: TextStyle(fontSize: 16)),
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
                  decoration: const InputDecoration(
                    hintText: "0",
                    suffixText: "%",
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          buildRow('Tổng cộng:', total,
              isBold: true, color: AppColors.primary),

          const SizedBox(height: 30), // Thay vì Spacer()

          // 🔘 Nút hành động
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isCompleted)
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle,
                      color: AppColors.primaryDark),
                  label: const Text("Hoàn thành đơn",
                      style: TextStyle(color: AppColors.dark)),
                  onPressed: widget.onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.primaryDark),
                    ),
                    elevation: 2,
                  ),
                ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text("Xuất hóa đơn",
                    style: TextStyle(color: Colors.white)),
                onPressed: () async {
                  print("👉 Đang tạo file PDF...");
                  await generateAndSavePdf(
                    context,
                    billId: widget.billId,
                    tableName: widget.tableName,
                    orderedItems: widget.orderedItems,
                    subtotal: widget.subtotal,
                    tax: widget.tax,
                    discountPercent: discountPercent,
                  );
                  print("✅ File đã tạo xong");
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildRow(String title, double amount,
      {bool isBold = false, Color color = AppColors.text}) {
    final currencyFormatter = NumberFormat.decimalPattern('vi');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${currencyFormatter.format(amount)} đồng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
