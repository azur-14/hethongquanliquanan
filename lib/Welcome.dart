import 'package:flutter/material.dart';
import 'menu.dart';
import 'KitchenMenuScreen.dart';
import 'thongke.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String? selectedRole;
  String? selectedTable;
  final List<String> roles = [
    'Quản lý',
    'Nhân viên phục vụ',
    'Nhân viên bếp',
  ];
  final List<String> tables = List.generate(10, (index) => 'Bàn ${index + 1}');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Ảnh góc trên trái
          Positioned(
            top: 0,
            left: 0,
            child: Image.asset(
              'assets/welcome_right.jpg',
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),
          // Ảnh góc dưới phải
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/welcome_left.jpg',
              width: MediaQuery.of(context).size.width * 0.4,
            ),
          ),

          // Nội dung chính
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

                        // Chọn vai trò
                        Container(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: DropdownButtonFormField<String>(
                            value: selectedRole,
                            decoration: InputDecoration(
                              labelText: 'Chọn vai trò của bạn',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                            items: roles.map((role) {
                              return DropdownMenuItem(value: role, child: Text(role));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                selectedRole = value;

                              });
                            },
                          ),
                        ),

                        SizedBox(height: 20),

                        // Nút Get Started
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
                            onPressed: () {
                              if (selectedRole == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Vui lòng chọn vai trò')),
                                );
                                return;
                              }

                              if (selectedRole == 'Khách hàng' && selectedTable == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Vui lòng chọn bàn cho khách hàng')),
                                );
                                return;
                              }

                              // Dẫn đến các màn tương ứng
                              if (selectedRole == 'Quản lý') {
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
                                  MaterialPageRoute(
                                    builder: (_) => HomeScreen(
                                      role: selectedRole!,
                                      table: selectedRole == 'Khách hàng' ? selectedTable : null,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Text('Get Started', style: TextStyle(color: Colors.white, fontSize: 18)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Footer
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
}
