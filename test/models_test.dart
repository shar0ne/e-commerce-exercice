import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_riverpod/models/cart_item.dart';
import 'package:ecommerce_riverpod/models/filter_state.dart';
import 'package:ecommerce_riverpod/models/product.dart';
import 'package:ecommerce_riverpod/models/user_profile.dart';

void main() {
  group('Product Model Tests', () {
    test('Product constructor, getters, equality and JSON conversion', () {
      const product = Product(
        id: 'p1',
        title: 'Smartphone Pro',
        description: 'Super smartphone',
        price: 499.99,
        originalPrice: 599.99,
        rating: 4.8,
        reviewCount: 150,
        category: 'Électronique',
        imageUrl: 'https://example.com/image.jpg',
        galleryImages: ['https://example.com/image.jpg'],
        inStock: true,
        stockCount: 10,
        availableColors: ['Noir', 'Bleu'],
        availableSizes: ['128GB', '256GB'],
        isFeatured: true,
      );

      expect(product.id, 'p1');
      expect(product.title, 'Smartphone Pro');
      expect(product.name, 'Smartphone Pro');
      expect(product.image, 'https://example.com/image.jpg');
      expect(product.hasDiscount, isTrue);
      expect(product.discountPercentage, 17);

      final map = product.toMap();
      final fromJson = Product.fromJson(map);
      expect(fromJson, equals(product));
      expect(fromJson.hashCode, product.hashCode);
    });

    test('CartItem totals and equality', () {
      const product = Product(
        id: 'p1',
        title: 'Smartphone Pro',
        description: 'Super smartphone',
        price: 100.0,
        rating: 4.8,
        reviewCount: 150,
        category: 'Électronique',
        imageUrl: 'https://example.com/image.jpg',
        galleryImages: [],
        inStock: true,
        stockCount: 10,
      );

      final item1 = CartItem(id: 'p1_default', product: product, quantity: 3);
      expect(item1.unitPrice, 100.0);
      expect(item1.totalPrice, 300.0);

      final item2 = CartItem(id: 'p1_default', product: product, quantity: 3);
      expect(item1, equals(item2));
    });

    test('FilterState copyWith and reset', () {
      const filter = FilterState();
      expect(filter.selectedCategory, 'Tous');
      expect(filter.hasActiveFilters, isFalse);

      final modified = filter.copyWith(
        searchQuery: 'phone',
        selectedCategory: 'Électronique',
        inStockOnly: true,
      );
      expect(modified.hasActiveFilters, isTrue);

      final reset = modified.reset();
      expect(reset.hasActiveFilters, isFalse);
    });
  });
}
