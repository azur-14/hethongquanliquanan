import 'package:flutter/material.dart';
import 'dart:math';
import 'Sidebar.dart';

class GenerateSecretCode extends StatefulWidget {
  const GenerateSecretCode({Key? key}) : super(key: key);

  @override
  State<GenerateSecretCode> createState() => _GenerateSecretCodeState();
}

class _GenerateSecretCodeState extends State<GenerateSecretCode> {
  String? generatedCode = "AB12CD"; // Sample initial code

  String generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );
  }

  void generateNewCode() {
    setState(() {
      generatedCode = generateCode(); // Replace the current code with a new one
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
                constraints: const BoxConstraints(maxWidth: 500),
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
                      "Tạo mã bí mật mới",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2e2e48),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Display current generated code
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color:  Color(0xFF2e2e48)),
                      ),
                      child: Text(
                        generatedCode ?? '-----',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2e2e48),
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.refresh, size: 28),
                        label: const Text("Tạo mã mới", style: TextStyle(fontSize: 18)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF2e2e48),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: generateNewCode,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Tạo mã mới vào ca sau.",
                      style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
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
