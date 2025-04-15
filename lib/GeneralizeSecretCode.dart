import 'dart:math';

import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Shift {
  final int shiftId;
  final String name;
  final String secretCode;

  Shift({required this.shiftId, required this.name, required this.secretCode});

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      shiftId: json['shiftId'],
      name: json['name'],
      secretCode: json['secretCode'],
    );
  }
}

class GenerateSecretCode extends StatefulWidget {
  const GenerateSecretCode({Key? key}) : super(key: key);

  @override
  State<GenerateSecretCode> createState() => _GenerateSecretCodeState();
}

class _GenerateSecretCodeState extends State<GenerateSecretCode> {
  List<Shift> allShifts = [];

  @override
  void initState() {
    super.initState();
    fetchAllSecretCodes();
  }

  Future<void> generateNewSecretCodes() async {
    try {
      final uri = Uri.parse("http://localhost:3002/api/shifts/generate-secret-codes");

      final response = await http.put(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Cập nhật thành công các secretCode:");

        final List<Shift> fetchedShifts = data['shifts'].map<Shift>((json) {
          return Shift(
            shiftId: (json['shift_id']),
            name: json['name'],
            secretCode: json['newSecretCode'] ?? '-----',
          );
        }).toList();

        setState(() {
          allShifts = fetchedShifts;
        });

      } else {
        print("Lỗi khi cập nhật secretCode: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối tới API: $e");
    }
  }

  Future<void> fetchAllSecretCodes() async {
    try {
      final uri = Uri.parse("http://localhost:3002/api/shifts/secret-codes/all");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final shifts = data['shifts'] as List;

        setState(() {
          allShifts = shifts.map((e) => Shift.fromJson(e)).toList();
        });
      } else {
        print("Lỗi server khi lấy secretCode: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối tới API: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: Row(
        children: [
          Sidebar(
            selectedItem: "Generate Code",
            role: "Quản lý",
            onSelectItem: (_) {},
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(30),
                constraints: const BoxConstraints(maxWidth: 600),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Mã bí mật theo từng ca",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2e2e48),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (allShifts.isEmpty)
                      const CircularProgressIndicator()
                    else
                      ...allShifts.map((shift) =>
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Color(0xFF2e2e48)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  shift.name,
                                  style: const TextStyle(fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  shift.secretCode,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2e2e48),
                                    letterSpacing: 6,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 28),
                        label: const Text(
                            "Tạo mã mới cho tất cả ca", style: TextStyle(
                            fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2e2e48),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          await generateNewSecretCodes();
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Nhấn nút để tạo mã mới cho toàn bộ các ca trong ngày.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}