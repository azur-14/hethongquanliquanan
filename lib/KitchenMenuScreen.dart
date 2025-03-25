import 'package:flutter/material.dart';

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
          Container(
            width: 200,
            color: Color(0xFF2F2F3E),
            child: Column(
              children: [
                SizedBox(height: 40),
                Text("EatEasy", style: TextStyle(color: Colors.orange, fontSize: 22)),
                SizedBox(height: 40),
                SidebarButton(icon: Icons.restaurant_menu, label: "MÓN ĂN", selected: true),
                SidebarButton(icon: Icons.list_alt, label: "ĐƠN MÓN", selected: false),
                Spacer(),
                SidebarButton(icon: Icons.logout, label: "Thoát", selected: false),
                SizedBox(height: 30),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: filters.map((f) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: FilterChip(
                          label: Text(f),
                          selected: selectedFilter == f,
                          onSelected: (_) {
                            setState(() => selectedFilter = f);
                          },
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onChanged: (value) => setState(() => searchQuery = value),
                  ),
                  SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                          ),
                          child: Column(
                            children: [
                              Image.asset(item['image'], width: 80, height: 80),
                              SizedBox(height: 10),
                              Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                              Spacer(),
                              Switch(
                                value: item['available'],
                                onChanged: (val) {
                                  setState(() {
                                    item['available'] = val;
                                  });
                                },
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

class SidebarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const SidebarButton({
    required this.icon,
    required this.label,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      decoration: selected
          ? BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(10))
          : null,
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(label, style: TextStyle(color: Colors.white)),
        onTap: () {},
      ),
    );
  }
}