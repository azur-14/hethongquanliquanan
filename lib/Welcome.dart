import 'package:flutter/material.dart';
import 'menu.dart';
import 'KitchenMenuScreen.dart';
import 'thongke.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? selectedRole;
  final TextEditingController passwordController = TextEditingController();
  final List<String> roles = [
    'Quản lý',
    'Nhân viên phục vụ',
    'Nhân viên bếp',
  ];

  String? managerPassword;

  @override
  void initState() {
    super.initState();
    checkAdminPassword();
  }

  void validateAndNavigate() {
    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Vui lòng chọn vai trò')),
      );
      return;
    }

    if (selectedRole == 'Quản lý') {
      if (passwordController.text != managerPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Mật khẩu sai!')),
        );
        return;
      }
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => BillStatisticsScreen()),
      );
    } else if (selectedRole == 'Nhân viên bếp') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => KitchenMenuScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(role: selectedRole!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/welcome_right.jpg',
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/welcome_left.jpg',
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          Column(
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'WELCOME BACK!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Ready to have a full digital experience in our restaurant',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Chọn vai trò của bạn',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: roles
                                .map((role) => DropdownMenuItem(value: role, child: Text(role)))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;
                                passwordController.clear();
                              });
                            },
                          ),
                        ),
                        SizedBox(height: 15),
                        if (selectedRole == 'Quản lý')
                          Container(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Mật khẩu quản lý",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                          ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              padding: EdgeInsets.symmetric(vertical: 15),
                              elevation: 5,
                              shadowColor: Colors.orangeAccent,
                            ),
                            onPressed: validateAndNavigate,
                            child: Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 50),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: TextStyle(fontSize: 32, color: Colors.black87),
                            children: [
                              TextSpan(text: 'Eat', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(
                                text: 'Easy',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(right: 40),
                          child: Text(
                            'Are you tired of scrolling through menus and struggling to decide\n'
                                'what to order? Our new restaurant app has got you covered\n'
                                'with personalized recommendations from our digital assistant.',
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<String?> fetchAdminPassword() async {
    try {
      final uri = Uri.parse("http://localhost:3003/api/users/password/admin");
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['password']; // 👈 Lấy mật khẩu từ JSON
      } else {
        print("Lỗi server: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return null;
    }
  }

  void checkAdminPassword() async {
    managerPassword = await fetchAdminPassword();
    if (managerPassword != null) {
      print("Success");
    } else {
      print("Không thể lấy mật khẩu admin.");
    }
  }

}

