import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'productdetail.dart'; // Import หน้า productdetail.dart

class ShowFilterType extends StatefulWidget {
  final String category; // หมวดหมู่สินค้า

  const ShowFilterType({super.key, required this.category});

  @override
  State<ShowFilterType> createState() => _ShowFilterTypeState();
}

class _ShowFilterTypeState extends State<ShowFilterType> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref('products');
  List<Map<String, dynamic>> products = [];

  Future<void> fetchProducts() async {
    try {
      // ดึงข้อมูลสินค้าจาก Firebase ตาม category
      final snapshot =
          await dbRef.orderByChild('category').equalTo(widget.category).get();

      if (snapshot.exists) {
        List<Map<String, dynamic>> loadedProducts = [];
        for (var child in snapshot.children) {
          Map<String, dynamic> product =
              Map<String, dynamic>.from(child.value as Map);
          loadedProducts.add(product);
        }

        setState(() {
          products = loadedProducts;
        });
      } else {
        print("ไม่พบสินค้าในหมวดหมู่ ${widget.category}");
      }
    } catch (e) {
      print("Error loading products: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สินค้าในหมวด: ${widget.category}'),
        backgroundColor: Color.fromARGB(255, 82, 233, 213),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(product['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('รายละเอียด: ${product['description']}'),
                        Text('ราคา: ${product['price']} บาท'),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetail(
                              product:
                                  product), // ส่งข้อมูลสินค้าไปยังหน้าถัดไป
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
