import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetail extends StatelessWidget {
  final Map<String, dynamic> product; // รับข้อมูลสินค้าที่ส่งมาจากหน้าก่อนหน้า

  const ProductDetail({super.key, required this.product});
  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd/MMMM/yyyy').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']), // แสดงชื่อสินค้าใน AppBar
        backgroundColor: Color.fromARGB(255, 58, 235, 52),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // รายละเอียดสินค้า
            Text(
              product['name'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ราคา: ${product['price']} บาท',
              style: const TextStyle(
                fontSize: 18,
                color: Color.fromARGB(255, 13, 72, 124),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'รายละเอียดสินค้า:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product['description'] ?? 'ไม่มีรายละเอียดสินค้า',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              'วันที่ผลิต: ${formatDate(product['productionDate'])}',
              style: const TextStyle(fontSize: 16),
            ),
            const Spacer(),
            // ปุ่มดำเนินการ (ถ้ามี)
            Row(
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // กลับไปหน้าก่อนหน้า
                    },
                    child: const Text('กลับ'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
