import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'models/Food.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class KitchenMenuScreen extends StatefulWidget {
  const KitchenMenuScreen({Key? key}) : super(key: key);

  @override
  State<KitchenMenuScreen> createState() => _KitchenMenuScreenState();
}

class _KitchenMenuScreenState extends State<KitchenMenuScreen> {
  List<Food> menuItems = [];

  String selectedFilter = 'Tất cả';
  final filters = ['Tất cả', 'Món chay', 'Đồ uống'];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchFoodItems();
  }

  List<Food> get filteredItems {
    return menuItems.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory = selectedFilter == 'Tất cả' || item.categoryName == selectedFilter;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Row(
        children: [
          Sidebar(
            selectedItem: "Món ăn",
            role: "Nhân viên bếp",
            onSelectItem: (_) {},
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: filters.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: ChoiceChip(
                          label: Text(f),
                          selectedColor: Colors.orangeAccent,
                          selected: selectedFilter == f,
                          onSelected: (_) {
                            setState(() => selectedFilter = f);
                            fetchFoodItems();
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm món...',
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.shade200,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                    ),
                    onChanged: (value) {
                      setState(() => searchQuery = value);
                      fetchFoodItems();
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 5 : 4,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: const [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 4))
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  item.image ?? '',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset('assets/food.jpg', width: 80, height: 80, fit: BoxFit.cover);
                                  },
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const Spacer(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 300),
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: item.status == "active"
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    activeColor: Colors.green,
                                    inactiveThumbColor: Colors.redAccent,
                                    value: item.status == "active",
                                    onChanged: (val) async {
                                      final newStatus = val ? "active" : "inactive";

                                      try {
                                        final uri = Uri.parse("http://localhost:3001/api/foods/${item.id}/status");
                                        final response = await http.put(
                                          uri,
                                          headers: {"Content-Type": "application/json"},
                                          body: jsonEncode({"status": newStatus}),
                                        );

                                        if (response.statusCode == 200) {
                                          setState(() {
                                            item.status = newStatus;
                                          });
                                        } else {
                                          print("Lỗi khi cập nhật trạng thái: ${response.body}");
                                        }
                                      } catch (e) {
                                        print("Lỗi kết nối khi cập nhật trạng thái: $e");
                                      }
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                item.status == "active"
                                    ? "Đủ nguyên liệu"
                                    : "Hết nguyên liệu",
                                style: TextStyle(
                                    color: item.status == "active"
                                        ? Colors.green
                                        : Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchFoodItems() async {
    try {
      final uri = Uri.parse("http://localhost:3001/api/foods?search=$searchQuery&categoryName=${selectedFilter == 'Tất cả' ? '' : selectedFilter}");

      final response = await http.get(uri);
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          menuItems = data.map((item) => Food.fromJson(item)).toList();
        });
      } else {
        print("Lỗi khi lấy danh sách món ăn: ${response.statusCode}");
      }
    } catch (e) {
      print("Lỗi kết nối đến server: $e");
    }
  }

}
