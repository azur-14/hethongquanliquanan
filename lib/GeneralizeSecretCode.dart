import 'dart:math';

import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Shift {
  final String id;
  final String name;
  String secretCode;

  Shift({required this.id, required this.name, required this.secretCode});

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['_id'],
      name: json['name'],
      secretCode: json['secretCode'] ?? '-----',
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
    fetchShifts();
  }

  void fetchShifts() {
    setState(() {
      allShifts = [
        Shift(id: '1', name: 'Ca sáng', secretCode: 'ABCDEF'),
        Shift(id: '2', name: 'Ca trưa', secretCode: 'ABCDEF'),
        Shift(id: '3', name: 'Ca chiều', secretCode: 'ABCDEF'),
        Shift(id: '4', name: 'Ca tối', secretCode: 'ABCDEF'),
      ];
    });
  }

  String generateRandomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }

  Future<void> regenerateAllCodes() async {
    setState(() {
      allShifts = allShifts.map((shift) {
        shift.secretCode = generateRandomCode();
        return shift;
      }).toList();
    });
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
                        onPressed: regenerateAllCodes,
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