import 'dart:io' as io show File, Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import 'models/Bill.dart';

Future<void> generateAndSavePdf(
    BuildContext context, {
      required String billId,
      required String tableName,
      required List<BillItem> orderedItems,
      required double subtotal,
      required double tax,
      required double discountPercent,
    }) async {
  final pdf = pw.Document();

  final font = await pw.Font.ttf(
    await rootBundle.load('assets/fonts/Roboto-Regular.ttf'),
  );
  final currencyFormatter = NumberFormat.decimalPattern('vi');
  double discountAmount = subtotal * (discountPercent / 100);
  double total = subtotal + tax - discountAmount;

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          // Header
          pw.Center(
            child: pw.Text('Quán Ăn Nhà Hàng SOA',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold)),
          ),

          pw.SizedBox(height: 20),
          pw.Text('Mã hóa đơn: $billId', style: pw.TextStyle(font: font)),
          pw.Text('Bàn: $tableName', style: pw.TextStyle(font: font)),
          pw.SizedBox(height: 20),

          // Bảng món ăn
          pw.Text('Danh sách món:',
              style: pw.TextStyle(
                  font: font,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Table.fromTextArray(
            cellStyle: pw.TextStyle(font: font, fontSize: 11),
            headerStyle: pw.TextStyle(
                font: font, fontWeight: pw.FontWeight.bold, fontSize: 12),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(2),
            },
            headers: ['Tên món', 'Số lượng', 'Đơn giá', 'Thành tiền'],
            data: orderedItems
                .map((item) => [
              item.name,
              item.qty.toString(),
              '${item.price.toStringAsFixed(2)}',
              '${(item.price * item.qty).toStringAsFixed(2)}'
            ])
                .toList(),
          ),

          pw.SizedBox(height: 20),

          // Tổng tiền
          pw.Divider(),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('Tạm tính: ${currencyFormatter.format(subtotal)} đồng',
                    style: pw.TextStyle(font: font)),
                pw.Text('Thuế: ${currencyFormatter.format(tax)} đồng',
                    style: pw.TextStyle(font: font)),
                pw.Text('Giảm giá: -${discountAmount.toStringAsFixed(2)}',
                    style: pw.TextStyle(font: font)),
                pw.SizedBox(height: 6),
                pw.Text('TỔNG CỘNG: ${currencyFormatter.format(total)} đồng',
                    style: pw.TextStyle(
                        font: font,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold)),
              ],
            ),
          ),

          pw.Spacer(),

          // Footer
          pw.Center(
            child: pw.Text('Cảm ơn quý khách đã sử dụng dịch vụ!',
                style: pw.TextStyle(
                    font: font,
                    fontSize: 12,
                    fontStyle: pw.FontStyle.italic)),
          ),
        ],
      ),
    ),
  );

  final bytes = await pdf.save();

  if (kIsWeb) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "hoadon_$billId.pdf")
      ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Đã tải file PDF xuống.")),
    );
  } else {
    final dir = await getApplicationDocumentsDirectory();
    final file = io.File('${dir.path}/hoadon_$billId.pdf');
    await file.writeAsBytes(bytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("✅ Đã lưu file PDF: ${file.path}")),
    );
  }
}
