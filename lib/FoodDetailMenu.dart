import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodDetailModal extends StatefulWidget {
  final String name;
  final String price;
  final String image;
  final String description;
  final int quantity;
  final String? orderId;
  final String? foodId;
  final Function(int) onQuantityChanged;

  FoodDetailModal({
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.quantity,
    required this.onQuantityChanged,
    this.orderId,
    this.foodId,
  });

  @override
  _FoodDetailModalState createState() => _FoodDetailModalState();
}

class _FoodDetailModalState extends State<FoodDetailModal> {
  double totalPrice = 0;
  int quantity = 1;
  String request = "";
  final int maxRequestLength = 250;

  @override
  void initState() {
    super.initState();
    quantity = widget.quantity > 0 ? widget.quantity : 1;
  }

  @override
  Widget build(BuildContext context) {
    totalPrice = double.parse(widget.price.replaceAll("\$", "")) * quantity;

    return Stack(
      children: [
        // Dimmed Background (Click to close)
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            color: Colors.black.withOpacity(0.5),
            width: double.infinity,
            height: double.infinity,
          ),
        ),

        // Sliding Modal
        Align(
          alignment: Alignment.centerRight,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: MediaQuery.of(context).size.width * 0.5,
            height: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(-5, 0)),
              ],
            ),

            // 🔥 Wrap with Material to fix TextField Error
            child: Material(
              color: Colors.transparent,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Close Button
                    Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        icon: Icon(Icons.close, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Image at the top
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.network(
                          widget.image,
                          width: 180,
                          height: 180,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/food.jpg', width: 180, height: 180, fit: BoxFit.cover);
                          },
                        ),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Food Name & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(widget.name, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                        Text("\$${totalPrice.toStringAsFixed(2)}",
                            style: TextStyle(fontSize: 18, color: Colors.orange, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    SizedBox(height: 10),

                    // Description
                    Text(
                      widget.description,
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),

                    SizedBox(height: 20),

                    // Request Input Field
                    Text("Add a request", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    TextField(
                      maxLength: maxRequestLength,
                      decoration: InputDecoration(
                        hintText: "Ex: Don't add onion",
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      ),
                      onChanged: (value) {
                        setState(() {
                          request = value;
                        });
                      },
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "${request.length}/$maxRequestLength",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ),

                    SizedBox(height: 15),

                    // Quantity and Order Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Quantity Selector
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              },
                            ),
                            Text("$quantity", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                            ),
                          ],
                        ),

                        // "GỌI MÓN" Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            await addOrderDetail();
                            widget.onQuantityChanged(quantity);
                            Navigator.pop(context);
                          },
                          child: Text("GỌI MÓN", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),

                    SizedBox(height: 20), // Extra spacing to prevent bottom overflow
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> addOrderDetail() async {
    final uri = Uri.parse("http://localhost:3001/api/orderdetail");

    final body = {
      "orderId": widget.orderId,
      "foodId": widget.foodId,
      "quantity": quantity,
      "price": totalPrice,
      "ne": request,
    };

    final response = await http.post(
      uri,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 201) {
      print("✅ OrderDetail đã được thêm");
    } else {
      print("❌ Lỗi thêm OrderDetail: ${response.body}");
    }
  }

}
