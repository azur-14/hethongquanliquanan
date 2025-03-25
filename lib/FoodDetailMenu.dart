import 'package:flutter/material.dart';

class FoodDetailModal extends StatefulWidget {
  final String name;
  final String price;
  final String image;
  final int quantity;
  final Function(int) onQuantityChanged;

  FoodDetailModal({
    required this.name,
    required this.price,
    required this.image,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  _FoodDetailModalState createState() => _FoodDetailModalState();
}

class _FoodDetailModalState extends State<FoodDetailModal> {
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
    double totalPrice = double.parse(widget.price.replaceAll("\$", "")) * quantity;

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
                        child: Image.asset(widget.image, width: 180, height: 180, fit: BoxFit.cover),
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
                      "Delicious and healthy meal to boost your energy. Made with fresh ingredients.",
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
                          onPressed: () {
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
}
