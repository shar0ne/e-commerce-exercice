import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';
import 'mock_products.dart';

abstract class IProductRepository {
  Future<List<Product>> getProducts({bool simulateError = false});
  Future<Product?> getProductById(String id);
  Future<List<String>> getCategories();
  Future<List<Product>> searchProducts(String query);
}

typedef ProductRepository = IProductRepository;

class MockProductRepository implements IProductRepository {
  List<Product>? _cachedProducts;

  @override
  Future<List<Product>> getProducts({bool simulateError = false}) async {
    // Artificial latency for AsyncValue demo
    await Future.delayed(const Duration(milliseconds: 600));

    if (simulateError) {
      throw Exception('Erreur de connexion au serveur (500). Veuillez réessayer.');
    }

    if (_cachedProducts != null && _cachedProducts!.isNotEmpty) {
      return List.unmodifiable(_cachedProducts!);
    }

    try {
      final jsonString = await rootBundle.loadString('assets/products.json');
      final List<dynamic> list = jsonDecode(jsonString);
      _cachedProducts = list.map((item) => Product.fromMap(item as Map<String, dynamic>)).toList();
    } catch (_) {
      _cachedProducts = List.from(mockProductsData);
    }

    return List.unmodifiable(_cachedProducts!);
  }

  @override
  Future<Product?> getProductById(String id) async {
    final products = await getProducts();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    final products = await getProducts();
    final categories = products.map((p) => p.category).toSet().toList();
    categories.sort();
    return ['Tous', ...categories];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final products = await getProducts();
    if (query.isEmpty) return products;
    final q = query.toLowerCase();
    return products.where((p) {
      return p.title.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q) ||
          p.description.toLowerCase().contains(q);
    }).toList();
  }
}
