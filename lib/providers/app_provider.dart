import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';

class AppProvider extends ChangeNotifier {
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('products');
      
      if (productsJson != null) {
        final List<dynamic> decoded = json.decode(productsJson);
        _products = decoded.map((e) => Product.fromJson(e)).toList();
      }
    } catch (e) {
      debugPrint('خطأ في التحميل: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) async {
    _products.add(product);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      await _saveProducts();
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    await _saveProducts();
    notifyListeners();
  }

  Future<void> _saveProducts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = json.encode(
        _products.map((e) => e.toJson()).toList(),
      );
      await prefs.setString('products', productsJson);
    } catch (e) {
      debugPrint('خطأ في الحفظ: $e');
    }
  }

  Product? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.trim().isEmpty) return _products;
    final cleanQuery = query.trim().toLowerCase();
    
    return _products.where((p) => 
      p.name.toLowerCase().contains(cleanQuery) ||
      p.barcode.contains(cleanQuery)
    ).toList();
  }
}
