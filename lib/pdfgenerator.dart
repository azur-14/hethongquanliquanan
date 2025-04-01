import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'models/Bill.dart';
import 'package:path_provider/path_provider.dart';

Future<void> generateAndSavePdf(Bill bill, double tax, double discountPercent) async {
  final pdf = pw.Document();

  final discountAmount = bill.total * discountPercent / 100;
  final total = bill.total + tax - discountAmount;

  pdf.addPage(
    pw.Page(
      build: (pw.Context context) {
        return pw.Padding(
          padding: const pw.EdgeInsets.all(24),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('HÓA ĐƠN THANH TOÁN',
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text('Bàn: ${bill.table}'),
              pw.Text('Mã đơn: ${bill.billId}'),
              pw.SizedBox(height: 12),
              pw.Divider(),
              ...bill.items.map((item) {
                return pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Expanded(child: pw.Text(item.name)),
                    pw.Text('${item.qty} × \$${item.price.toStringAsFixed(2)}'),
                  ],
                );
              }).toList(),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tạm tính:'),
                  pw.Text('\$${bill.total.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Thuế:'),
                  pw.Text('\$${tax.toStringAsFixed(2)}'),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Giảm giá:'),
                  pw.Text('-\$${discountAmount.toStringAsFixed(2)}'),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TỔNG CỘNG:',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('\$${total.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
        );
      },
    ),
  );

  final bytes = await pdf.save();
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/HoaDon_${bill.billId}.pdf');
  await file.writeAsBytes(bytes);

  print('✅ File PDF đã lưu tại: ${file.path}');
}
