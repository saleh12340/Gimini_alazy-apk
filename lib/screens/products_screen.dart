import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final products = provider.searchProducts(_searchController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة المنتجات'),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'بحث باسم المنتج أو الباركود',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          Expanded(
            child: products.isEmpty
                ? const Center(child: Text('لا توجد منتجات مسجلة'))
                : ListView.builder(
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Text(
                            '${product.quantity}',
                            style: TextStyle(color: Colors.green[900]),
                          ),
                        ),
                        title: Text(product.name),
                        subtitle: Text('السعر: ${product.price} | الباركود: ${product.barcode}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => provider.deleteProduct(product.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green[800],
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () => _showAddProductDialog(context),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final quantityController = TextEditingController();
    final barcodeController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة منتج جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المنتج')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number),
              TextField(controller: quantityController, decoration: const InputDecoration(labelText: 'الكمية'), keyboardType: TextInputType.number),
              TextField(controller: barcodeController, decoration: const InputDecoration(labelText: 'الباركود')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                final newProduct = Product(
                  id: DateTime.now().toString(),
                  name: nameController.text,
                  price: double.tryParse(priceController.text) ?? 0.0,
                  cost: 0.0,
                  quantity: int.tryParse(quantityController.text) ?? 0,
                  barcode: barcodeController.text,
                );
                Provider.of<AppProvider>(context, listen: false).addProduct(newProduct);
                Navigator.pop(ctx);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }
}
