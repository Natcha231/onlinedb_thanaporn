import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Class stateful เรียกใช้การทํางานแบบโต้ตอบ
class ShowProductgrid extends StatefulWidget {
  const ShowProductgrid({super.key});

  @override
  State<ShowProductgrid> createState() => _ShowProductgridState();
}

class _ShowProductgridState extends State<ShowProductgrid> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref('products');
  List<Map<String, dynamic>> products = [];

  Future<void> fetchProducts() async {
    try {
      // ดึงข้อมูลจาก Realtime Database
      final snapshot = await dbRef.get();
      if (snapshot.exists) {
        List<Map<String, dynamic>> loadedProducts = [];

        // วนลูปเพื่อแปลงข้อมูลเป็น Map
        for (var child in snapshot.children) {
          Map<String, dynamic> product =
              Map<String, dynamic>.from(child.value as Map);
          product['key'] = child.key;
          product['name'] = product['name'].toString();
          product['description'] = product['description']?.toString() ?? '';
          product['price'] = product['price']?.toString() ?? '0';
          product['quantity'] = product['quantity']?.toString() ?? '0';
          product['discount'] =
              product['discount']?.toString() ?? 'ไม่มีส่วนลด';
          product['productionDate'] =
              product['productionDate']?.toString() ?? '';

          loadedProducts.add(product);
        }

        // เรียงราคาสินค้าจากน้อยไปมาก
        loadedProducts.sort((a, b) => a['price'].compareTo(b['price']));

        // อัปเดต state เพื่อแสดงข้อมูล
        setState(() {
          products = loadedProducts;
        });

        print(
            "จํานวนรายการสินค้าทั้งหมด: ${products.length} รายการ"); // Debugging
      } else {
        print("ไม่พบรายการสินค้าในฐานข้อมูล"); // กรณีไม่มีข้อมูล
      }
    } catch (e) {
      print("Error loading products: $e"); // แสดงข้อผิดพลาดทาง Console

      // แสดง Snackbar เพื่อแจ้งเตือนผู้ใช้
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลดข้อมูล: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProducts(); // เรียกใช้เมื่อ Widget ถูกสร้าง
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd/MMMM/yyyy').format(parsedDate);
  }

  void deleteProduct(String key, BuildContext context) {
//คําสั่งลบโดยอ้างถึงตัวแปร dbRef ที่เชือมต่อตาราง product ไว้
    dbRef.child(key).remove().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบสินค้าเรียบร้อย')),
      );
      fetchProducts();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    });
  }

//ฟังก์ชันถามยืนยันก่อนลบ
  void showDeleteConfirmationDialog(String key, BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // ป้องกันการปิ ด Dialog โดยการแตะนอกพื้นที่
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('ยืนยันการลบ'),
          content: Text('คุณแน่ใจว่าต้องการลบสินค้านี้ใช่หรือไม่?'),
          actions: [
// ปุ่ มยกเลิก
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิ ด Dialog
              },
              child: Text('ไม่ลบ'),
            ),
// ปุ่ มยืนยันการลบ
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิ ด Dialog
                deleteProduct(key, context); // เรียกฟังก์ชันลบข้อมูล
//ข้อความแจ้งว่าลบเรียบร้อย
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('ลบข้อมูลเรียบร้อยแล้ว'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: Text('ลบ', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  //ฟังก์ชันแสดง AlertDialog หน้าจอเพื่อแก้ไขข้อมูล
  void showEditProductDialog(Map<String, dynamic> product) {
    //ตัวอย่างประกาศตัวแปรเพื่อเก็บค่าข้อมูลเดิมที่เก็บไว้ในฐานข้อมูล ดึงมาเก็บไว้ตัวแปรที่กําหนด
    TextEditingController nameController =
        TextEditingController(text: product['name']);
    TextEditingController descriptionController =
        TextEditingController(text: product['description']);
    TextEditingController categoryController =
        TextEditingController(text: product['category'] ?? 'ไม่ระบุ');
    TextEditingController productionDate =
        TextEditingController(text: product['productionDate']);
    TextEditingController priceController =
        TextEditingController(text: product['price'].toString());
    TextEditingController quantityController =
        TextEditingController(text: product['quantity'].toString());
    TextEditingController discountController = TextEditingController(
        text: product['discount']?.toString() ?? 'ไม่มีส่วนลด');
    //สร้าง dialog เพื่อแสดงข้อมูลเก่าและให้กรอกข้อมูลใหม่เพื่อแก้ไข
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        print(
            'Opening edit dialog for product: ${product['name']}'); // เพิ่มข้อความตรวจสอบ
        return AlertDialog(
          title: Text('แก้ไขสินค้า'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'ชื่อสินค้า'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(labelText: 'รายละเอียดสินค้า'),
                ),
                TextField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'ประเภทสินค้า'),
                ),
                TextField(
                  controller: quantityController,
                  decoration: InputDecoration(labelText: 'จำนวน'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: priceController,
                  decoration: InputDecoration(labelText: 'ราคา'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: productionDate,
                  decoration: InputDecoration(labelText: 'วันที่ผลิต'),
                ),
                TextField(
                  controller: discountController,
                  decoration: InputDecoration(labelText: 'ส่วนลด (%)'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(); // ปิ ด Dialog
              },
              child: Text('ยกเลิก'),
            ),
            TextButton(
              onPressed: () {
// เตรียมข้อมูลที่แก้ไขแล้ว
                Map<String, dynamic> updatedData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'category': categoryController.text,
                  'productionDate': productionDate.text.isNotEmpty
                      ? productionDate.text
                      : null,
                  'price': int.tryParse(priceController.text) ?? 0,
                  'quantity': int.tryParse(quantityController.text) ?? 0,
                  'discount': discountController.text.isNotEmpty
                      ? int.tryParse(discountController.text) ?? 0
                      : null,
                };
                dbRef.child(product['key']).update(updatedData).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('แก้ไขข้อมูลเรียบร้อย')),
                  );
                  fetchProducts(); // เรียกใช้ฟังก์ชันเพื่อโหลดข้อมูลใหม่เพื่อแสดงผลหลังการแก้ไขเช่น fetchProducts
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $error')),
                  );
                });
                Navigator.of(dialogContext).pop(); // ปิ ด Dialog
              },
              child: Text('บันทึก'),
            ),
          ],
        );
      },
    );
  }

  // ส่วนการออกแบบหน้าจอ
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('แสดงผลข้อมูลสินค้า'),
        backgroundColor: Color.fromARGB(255, 232, 243, 76),
      ),
      body: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // แถวละ 2 รายการ
                crossAxisSpacing: 8.0, // ระยะห่างระหว่างคอลัมน์
                mainAxisSpacing: 8.0, // ระยะห่างระหว่างแถว
                childAspectRatio: 2 / 1, // อัตราส่วนกว้างต่อสูงของแต่ละ Grid
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(15)),
                            color: Color.fromARGB(255, 241, 203, 75),
                          ),
                          child: Center(
                            child: Text(
                              product['name'],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'รายละเอียด: ${product['description']}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'วันที่ผลิต: ${formatDate(product['productionDate'])}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'ราคา: ${product['price']} บาท',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 252, 153, 41),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox(
                                width: 80,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[50], // พื้นหลังสีแดงอ่อน
                                    shape: BoxShape.circle, // รูปทรงวงกลม
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      // กดปุ่ มลบแล้วจะให้เกิดอะไรขึ้น
                                      showDeleteConfirmationDialog(
                                          product['key'], context);
                                    },
                                    icon: Icon(Icons.delete),
                                    color: Colors.red, // สีของไอคอน
                                    iconSize: 30,
                                    tooltip: 'ลบสินค้า',
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox(
                                width: 80,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red[50], // พื้นหลังสีแดงอ่อน
                                    shape: BoxShape.circle, // รูปทรงวงกลม
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      // กดปุ่ มลบแล้วจะให้เกิดอะไรขึ้น
                                      showEditProductDialog(
                                          product); // เปด Dialog แกไขสินคา
                                    },
                                    icon: Icon(Icons.edit),
                                    color: Colors.red, // สีของไอคอน
                                    iconSize: 30,
                                    tooltip: 'แก้ไขสินค้า',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
