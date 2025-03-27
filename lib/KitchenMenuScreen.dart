import 'package:flutter/material.dart';
import 'Sidebar.dart';

class KitchenMenuScreen extends StatefulWidget {
  const KitchenMenuScreen({Key? key}) : super(key: key);

  @override
  State<KitchenMenuScreen> createState() => _KitchenMenuScreenState();
}

class _KitchenMenuScreenState extends State<KitchenMenuScreen> {
  List<Map<String, dynamic>> menuItems = [
    {'name': 'Egg Toast', 'image': 'assets/food.jpg', 'available': true},
    {'name': 'Power Bowl', 'image': 'assets/food.jpg', 'available': true},
    {'name': 'Mac and Cheese', 'image': 'assets/food.jpg', 'available': false},
    {'name': 'Curry Salmon', 'image': 'assets/food.jpg', 'available': true},
    {'name': 'Yogurt and Fruits', 'image': 'assets/food.jpg', 'available': false},
  ];

  String selectedFilter = 'Tất cả';
  final filters = ['Tất cả', 'Món chay', 'Đồ uống'];
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredItems = menuItems
        .where((item) => item['name'].toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

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
                    onChanged: (value) => setState(() => searchQuery = value),
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
                                child: Image.asset(
                                  item['image'],
                                  width: double.infinity,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item['name'],
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
                                      color: item['available']
                                          ? Colors.green
                                          : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    activeColor: Colors.green,
                                    inactiveThumbColor: Colors.redAccent,
                                    value: item['available'],
                                    onChanged: (val) {
                                      setState(() {
                                        item['available'] = val;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Text(
                                item['available']
                                    ? "Đủ nguyên liệu"
                                    : "Hết nguyên liệu",
                                style: TextStyle(
                                    color: item['available']
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
}
