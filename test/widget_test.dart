import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_riverpod/main.dart';
import 'package:ecommerce_riverpod/src/models/filter_state.dart';
import 'package:ecommerce_riverpod/src/providers/providers.dart';
import 'package:ecommerce_riverpod/src/data/mock_products.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CartNotifier adds items and calculates subtotal properly', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    final product = mockProductsData.first;

    // Initially empty
    expect(container.read(cartNotifierProvider), isEmpty);
    expect(container.read(cartSummaryProvider).totalItemCount, 0);

    // Add item
    container.read(cartNotifierProvider.notifier).addItem(product, quantity: 2);

    expect(container.read(cartNotifierProvider).length, 1);
    expect(container.read(cartNotifierProvider).first.quantity, 2);
    expect(container.read(cartSummaryProvider).totalItemCount, 2);
    expect(container.read(cartSummaryProvider).subtotal, closeTo(product.price * 2, 0.01));

    // Increase quantity
    final itemId = container.read(cartNotifierProvider).first.id;
    container.read(cartNotifierProvider.notifier).updateQuantity(itemId, 3);
    expect(container.read(cartNotifierProvider).first.quantity, 3);

    // Apply Promo code
    container.read(promoCodeProvider.notifier).state = 'RIVERPOD20';
    expect(container.read(cartSummaryProvider).discount, closeTo(product.price * 3 * 0.20, 0.01));

    // Clear cart
    container.read(cartNotifierProvider.notifier).clearCart();
    expect(container.read(cartNotifierProvider), isEmpty);
  });

  test('FilterNotifier and sorting works properly', () {
    final notifier = FilterNotifier();
    expect(notifier.state.selectedCategory, 'Tous');
    expect(notifier.state.sortOption, ProductSortOption.featured);

    notifier.setCategory('Électronique');
    expect(notifier.state.selectedCategory, 'Électronique');

    notifier.setSortOption(ProductSortOption.priceAsc);
    expect(notifier.state.sortOption, ProductSortOption.priceAsc);

    notifier.setPriceRange(50, 200);
    expect(notifier.state.minPrice, 50);
    expect(notifier.state.maxPrice, 200);

    notifier.reset();
    expect(notifier.state.selectedCategory, 'Tous');
    expect(notifier.state.sortOption, ProductSortOption.featured);
  });

  testWidgets('ShopFluxApp renders catalog navigation and app bar', (WidgetTester tester) async {
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ShopFluxApp(),
      ),
    );

    // Verify initial rendering
    expect(find.text('ShopFlux'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Favoris'), findsOneWidget);
    expect(find.text('Panier'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);

    // Advance timer past simulated network delay
    await tester.pumpAndSettle(const Duration(milliseconds: 1500));
  });
}
