import '../models/product.dart';
import 'mock_products.dart';

abstract class IProductRepository {
  Future<List<Product>> getProducts({bool simulateError = false});
  Future<Product?> getProductById(String id);
  Future<List<String>> getCategories();
}

class MockProductRepository implements IProductRepository {
  final List<Product> _products = List.from(mockProductsData);

  @override
  Future<List<Product>> getProducts({bool simulateError = false}) async {
    // Simulate network latency for realistic AsyncValue demo
    await Future.delayed(const Duration(milliseconds: 700));

    if (simulateError) {
      throw Exception('Échec de connexion au serveur (Erreur 500 simulée). Veuillez réessayer.');
    }

    return List.unmodifiable(_products);
  }

  @override
  Future<Product?> getProductById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<String>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final categories = _products.map((p) => p.category).toSet().toList();
    categories.sort();
    return ['Tous', ...categories];
  }
}
