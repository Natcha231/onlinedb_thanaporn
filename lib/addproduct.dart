import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'ShowProduct.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 101, 228, 107),
        ),
        useMaterial3: true,
      ),
      home: const AddProductPage(),
    );
  }
}

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController desController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final List<String> categories = ['Electronics', 'Clothing', 'Food', 'Books'];
  String? selectedCategory;
  DateTime? productionDate;
  String? selectedDiscountOption;

  Future<void> pickProductionDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: productionDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != productionDate) {
      setState(() {
        productionDate = pickedDate;
        dateController.text =
            "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
      });
    }
  }

  Future<void> saveProductToDatabase() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final DatabaseReference dbRef = FirebaseDatabase.instance.ref('products');
      final productData = {
        'name': nameController.text,
        'description': desController.text,
        'category': selectedCategory,
        'productionDate': productionDate?.toIso8601String(),
        'price': double.tryParse(priceController.text) ?? 0.0,
        'quantity': int.tryParse(quantityController.text) ?? 0,
        'discount': selectedDiscountOption,
      };

      await dbRef.push().set(productData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
      );
      Navigator.push(
context,
MaterialPageRoute(builder: (context) => ShowProduct()),
);

      clearForm();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
    }
  }

  void clearForm() {
    _formKey.currentState?.reset();
    nameController.clear();
    desController.clear();
    priceController.clear();
    quantityController.clear();
    dateController.clear();
    setState(() {
      selectedCategory = null;
      productionDate = null;
      selectedDiscountOption = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 74, 192, 228),
        title: const Text('เพิ่มสินค้า'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อสินค้า*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'กรุณากรอกชื่อสินค้า' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: desController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'รายละเอียดสินค้า*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'กรุณากรอกรายละเอียดสินค้า'
                      : null,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'ประเภทสินค้า',
                    border: OutlineInputBorder(),
                  ),
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedCategory = value),
                  validator: (value) =>
                      value == null ? 'กรุณากรอกประเภทสินค้า' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'วันที่ผลิต',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => pickProductionDate(context),
                    ),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'กรุณากรอกวันที่ผลิต'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'ราคาสินค้า*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || double.tryParse(value) == null)
                      ? 'กรุณากรอกราคาสินค้าเป็นจำนวนตัวเลข'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: quantityController,
                  decoration: const InputDecoration(
                    labelText: 'จำนวนสินค้า*',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => (value == null || int.tryParse(value) == null)
                      ? 'กรุณากรอกจำนวนสินค้าเป็นจำนวนตัวเลข'
                      : null,
                ),
                const SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ส่วนลด',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    RadioListTile<String>(
                      title: const Text('ให้ส่วนลด'),
                      value: 'true',
                      groupValue: selectedDiscountOption,
                      onChanged: (value) =>
                          setState(() => selectedDiscountOption = value),
                    ),
                    RadioListTile<String>(
                      title: const Text('ไม่ให้ส่วนลด'),
                      value: 'false',
                      groupValue: selectedDiscountOption,
                      onChanged: (value) =>
                          setState(() => selectedDiscountOption = value),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: saveProductToDatabase,
                      child: const Text('บันทึกสินค้า'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: clearForm,
                      style: ElevatedButton.styleFrom(
                       
                      ),
                      child: const Text('เคลียร์'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
