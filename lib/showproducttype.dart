import 'package:flutter/material.dart';
import 'showfiltertype.dart';

class ShowProductType extends StatelessWidget {
  const ShowProductType({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = ['Electronics', 'Clothing', 'Food', 'Books'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('ประเภทสินค้า'),
        backgroundColor: Color.fromARGB(255, 63, 165, 225),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // แถวละ 2 รายการ
          crossAxisSpacing: 8.0, // ระยะห่างระหว่างคอลัมน์
          mainAxisSpacing: 8.0, // ระยะห่างระหว่างแถว
          childAspectRatio: 1, // อัตราส่วนกว้างต่อสูงของแต่ละ Grid
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return GestureDetector(
            onTap: () {
              // เปลี่ยนไปยังหน้า showfiltertype พร้อมส่ง category ที่เลือกไป
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ShowFilterType(category: category), // ส่ง category ไป
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 2, 71, 168),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10), // ระยะห่างระหว่างข้อความกับไอคอน
                  Icon(
                    Icons.shopping_cart, // ไอคอนตะกร้า
                    size: 40,
                    color: const Color.fromARGB(255, 2, 71, 168),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
