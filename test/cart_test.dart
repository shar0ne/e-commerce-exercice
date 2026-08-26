import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_riverpod/models/product.dart';
import 'package:ecommerce_riverpod/providers/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('CartNotifier handles add, remove, increment, decrement and totals', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    const productA = Product(
      id: 'a1',
      title: 'Produit A',
      description: 'Desc A',
      price: 50.0,
      rating: 4.5,
      reviewCount: 10,
      category: 'Cat A',
      imageUrl: 'imgA',
      galleryImages: [],
      inStock: true,
      stockCount: 5,
    );

    final cartNotifier = container.read(cartNotifierProvider.notifier);

    // Initial state
    expect(container.read(cartNotifierProvider), isEmpty);
    expect(cartNotifier.totalItemsCount, 0);
    expect(cartNotifier.subtotal, 0.0);

    // Add item
    cartNotifier.addToCart(productA, 2);
    expect(container.read(cartNotifierProvider).length, 1);
    expect(cartNotifier.totalItemsCount, 2);
    expect(cartNotifier.subtotal, 100.0);
    expect(cartNotifier.isInCart(productA.id), isTrue);
    expect(cartNotifier.getItemQuantity(productA.id), 2);

    // Increment
    cartNotifier.increment(productA.id);
    expect(cartNotifier.getItemQuantity(productA.id), 3);
    expect(cartNotifier.subtotal, 150.0);

    // Decrement
    cartNotifier.decrement(productA.id);
    expect(cartNotifier.getItemQuantity(productA.id), 2);

    // Update quantity
    cartNotifier.updateQuantity(productA.id, 5);
    expect(cartNotifier.getItemQuantity(productA.id), 5);

    // Remove
    cartNotifier.removeFromCart(productA.id);
    expect(container.read(cartNotifierProvider), isEmpty);
    expect(cartNotifier.isInCart(productA.id), isFalse);
  });
}
