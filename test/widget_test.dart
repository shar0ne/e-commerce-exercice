import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_riverpod/main.dart';
import 'package:ecommerce_riverpod/src/models/filter_state.dart';
import 'package:ecommerce_riverpod/src/models/product.dart';
import 'package:ecommerce_riverpod/src/providers/providers.dart';
import 'package:ecommerce_riverpod/src/data/mock_products.dart';
import 'package:ecommerce_riverpod/src/data/product_repository.dart';
import 'package:ecommerce_riverpod/src/presentation/widgets/async_value_widget.dart';

class TestMockRepository implements IProductRepository {
  @override
  Future<List<Product>> getProducts({bool simulateError = false}) async {
    if (simulateError) {
      throw Exception('Erreur serveur simulée');
    }
    return mockProductsData;
  }

  @override
  Future<Product?> getProductById(String id) async {
    return mockProductsData.firstWhere((p) => p.id == id);
  }

  @override
  Future<List<String>> getCategories() async {
    return ['Tous', 'Électronique', 'Chaussures', 'Accessoires', 'Mode', 'Maison & Déco'];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    return mockProductsData;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Product Model Tests', () {
    test('Product serialization and getters work correctly', () {
      final product = mockProductsData.first;
      final json = product.toJson();

      expect(json['id'], product.id);
      expect(json['title'], product.title);
      expect(json['price'], product.price);

      final fromJson = Product.fromJson(json);
      expect(fromJson, equals(product));
      expect(fromJson.name, product.title);
      expect(fromJson.image, product.imageUrl);
      expect(fromJson.hasDiscount, isTrue);
      expect(fromJson.discountPercentage, greaterThan(0));
    });

    test('Product copyWith updates values', () {
      final product = mockProductsData.first;
      final updated = product.copyWith(price: 99.99, title: 'Nouveau Titre');
      expect(updated.price, 99.99);
      expect(updated.title, 'Nouveau Titre');
      expect(updated.id, product.id);
    });
  });

  group('CartNotifier & CartSummary Tests', () {
    test('CartNotifier operations: add, remove, increment, decrement, promo code', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final product1 = mockProductsData[0];
      final product2 = mockProductsData[1];

      final cartNotifier = container.read(cartNotifierProvider.notifier);

      // Initially empty
      expect(container.read(cartNotifierProvider), isEmpty);
      expect(container.read(cartSummaryProvider).totalItemCount, 0);
      expect(container.read(cartSummaryProvider).subtotal, 0.0);

      // Add product 1
      cartNotifier.addToCart(product1, 2);
      expect(container.read(cartNotifierProvider).length, 1);
      expect(container.read(cartSummaryProvider).totalItemCount, 2);
      expect(container.read(cartSummaryProvider).subtotal, closeTo(product1.price * 2, 0.01));
      expect(cartNotifier.isInCart(product1.id), isTrue);
      expect(cartNotifier.getItemQuantity(product1.id), 2);

      // Add product 2
      cartNotifier.addToCart(product2, 1);
      expect(container.read(cartNotifierProvider).length, 2);
      expect(container.read(cartSummaryProvider).totalItemCount, 3);

      // Increment
      cartNotifier.incrementQuantity(product1.id);
      expect(cartNotifier.getItemQuantity(product1.id), 3);

      // Decrement
      cartNotifier.decrementQuantity(product1.id);
      expect(cartNotifier.getItemQuantity(product1.id), 2);

      // Apply Promo Code
      container.read(promoCodeProvider.notifier).state = 'RIVERPOD20';
      final summary = container.read(cartSummaryProvider);
      expect(summary.discount, closeTo(summary.subtotal * 0.20, 0.01));
      expect(summary.total, greaterThan(0));

      // Remove product 2
      cartNotifier.removeFromCart(product2);
      expect(container.read(cartNotifierProvider).length, 1);

      // Clear cart
      cartNotifier.clearCart();
      expect(container.read(cartNotifierProvider), isEmpty);
      expect(container.read(cartSummaryProvider).totalItemCount, 0);
    });
  });

  group('FavoritesNotifier & Persistence Tests', () {
    test('FavoritesNotifier toggles and persists favorites', () async {
      final prefs = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );

      final favNotifier = container.read(favoritesNotifierProvider.notifier);
      final product = mockProductsData.first;

      expect(favNotifier.isFavorite(product.id), isFalse);

      // Toggle Add
      await favNotifier.toggleFavorite(product.id);
      expect(favNotifier.isFavorite(product.id), isTrue);
      expect(container.read(favoritesNotifierProvider).contains(product.id), isTrue);

      // Verify persistent storage in SharedPreferences
      expect(prefs.getStringList('user_favorite_product_ids'), contains(product.id));

      // Recreate container to verify reload from persistent storage
      final newContainer = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      expect(newContainer.read(favoritesNotifierProvider).contains(product.id), isTrue);

      // Toggle Remove
      await newContainer.read(favoritesNotifierProvider.notifier).toggleFavorite(product.id);
      expect(newContainer.read(favoritesNotifierProvider).contains(product.id), isFalse);
    });
  });

  group('FilterNotifier & Sorting Tests', () {
    test('FilterNotifier updates search, category, sort and price range', () {
      final notifier = FilterNotifier();

      expect(notifier.state.selectedCategory, 'Tous');
      expect(notifier.state.sortOption, ProductSortOption.featured);

      notifier.search('Casque');
      expect(notifier.state.searchQuery, 'Casque');

      notifier.filterByCategory('Électronique');
      expect(notifier.state.selectedCategory, 'Électronique');

      notifier.sortBy(ProductSortOption.priceDesc);
      expect(notifier.state.sortOption, ProductSortOption.priceDesc);

      notifier.setPriceRange(50, 300);
      expect(notifier.state.minPrice, 50);
      expect(notifier.state.maxPrice, 300);

      notifier.toggleInStockOnly();
      expect(notifier.state.inStockOnly, isTrue);

      notifier.toggleOnSaleOnly();
      expect(notifier.state.onSaleOnly, isTrue);

      expect(notifier.state.hasActiveFilters, isTrue);

      notifier.reset();
      expect(notifier.state.selectedCategory, 'Tous');
      expect(notifier.state.sortOption, ProductSortOption.featured);
      expect(notifier.state.hasActiveFilters, isFalse);
    });
  });

  group('ProductRepository Tests', () {
    test('MockProductRepository returns products and categories', () async {
      final repo = MockProductRepository();
      final products = await repo.getProducts();
      expect(products, isNotEmpty);

      final categories = await repo.getCategories();
      expect(categories, contains('Tous'));

      final searchResult = await repo.searchProducts('ANC');
      expect(searchResult, isNotEmpty);
    });

    test('MockProductRepository throws error on simulateError: true', () async {
      final repo = MockProductRepository();
      expect(() => repo.getProducts(simulateError: true), throwsException);
    });
  });

  group('Widget and UI Tests', () {
    testWidgets('AsyncValueWidget renders loading, data and error states with retry', (WidgetTester tester) async {
      // 1. Loading state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String>(
              value: const AsyncLoading(),
              data: (text) => Text('Data: $text'),
            ),
          ),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // 2. Data state
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String>(
              value: const AsyncData('Produit chargé'),
              data: (text) => Text('Data: $text'),
            ),
          ),
        ),
      );
      expect(find.text('Data: Produit chargé'), findsOneWidget);

      // 3. Error state with retry
      bool retryClicked = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AsyncValueWidget<String>(
              value: AsyncError(Exception('Connexion impossible'), StackTrace.empty),
              onRetry: () => retryClicked = true,
              data: (text) => Text('Data: $text'),
            ),
          ),
        ),
      );
      expect(find.text('Une erreur est survenue'), findsOneWidget);
      expect(find.text('Réessayer'), findsOneWidget);

      await tester.tap(find.text('Réessayer'));
      expect(retryClicked, isTrue);
    });

    testWidgets('ShopFluxApp renders correctly and handles navigation', (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            productRepositoryProvider.overrideWithValue(TestMockRepository()),
          ],
          child: const ShopFluxApp(),
        ),
      );

      // Initial pump
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // App Title and Nav
      expect(find.text('ShopFlux'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Catalogue'), findsOneWidget);
      expect(find.text('Favoris'), findsOneWidget);
      expect(find.text('Panier'), findsOneWidget);
      expect(find.text('Profil'), findsOneWidget);

      // Tap Favoris tab
      await tester.tap(find.text('Favoris'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Mes Favoris'), findsOneWidget);

      // Tap Panier tab
      await tester.tap(find.text('Panier'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Mon Panier'), findsOneWidget);

      // Tap Profil tab
      await tester.tap(find.text('Profil'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Profil & Paramètres'), findsOneWidget);
      expect(find.text('Mode Sombre (Dark Mode)'), findsOneWidget);
    });
  });
}
