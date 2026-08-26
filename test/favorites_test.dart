import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecommerce_riverpod/providers/providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('FavoritesNotifier toggles, adds, removes and persists favorites', () async {
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
    );

    final favNotifier = container.read(favoritesNotifierProvider.notifier);

    expect(favNotifier.isFavorite('p1'), isFalse);

    // Add favorite
    await favNotifier.addFavorite('p1');
    expect(favNotifier.isFavorite('p1'), isTrue);
    expect(container.read(favoritesNotifierProvider), contains('p1'));

    // Toggle off
    await favNotifier.toggleFavorite('p1');
    expect(favNotifier.isFavorite('p1'), isFalse);
    expect(container.read(favoritesNotifierProvider), isNot(contains('p1')));

    // Toggle on
    await favNotifier.toggleFavorite('p2');
    expect(favNotifier.isFavorite('p2'), isTrue);

    // Check SharedPreferences persistence
    expect(prefs.getStringList('user_favorite_product_ids'), contains('p2'));

    // Clear all
    await favNotifier.clearAll();
    expect(container.read(favoritesNotifierProvider), isEmpty);
  });
}
