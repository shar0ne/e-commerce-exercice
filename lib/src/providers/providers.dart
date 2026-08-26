import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/favorites_storage.dart';
import '../data/product_repository.dart';
import '../models/cart_item.dart';
import '../models/filter_state.dart';
import '../models/product.dart';
import '../models/user_profile.dart';

// ==========================================
// 1. Dependency Providers
// ==========================================

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in ProviderScope');
});

final favoritesStorageProvider = Provider<FavoritesStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return FavoritesStorage(prefs);
});

final productRepositoryProvider = Provider<IProductRepository>((ref) {
  return MockProductRepository();
});

// Toggle to simulate server error for testing AsyncValue error state
final simulateErrorProvider = StateProvider<bool>((ref) => false);

// ==========================================
// 2. Product Providers (FutureProvider & AsyncValue)
// ==========================================

final productsFutureProvider = FutureProvider.autoDispose<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  final simulateError = ref.watch(simulateErrorProvider);
  return repository.getProducts(simulateError: simulateError);
});

final categoriesProvider = FutureProvider.autoDispose<List<String>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return repository.getCategories();
});

// ==========================================
// 3. Filter & Sort StateNotifierProvider
// ==========================================

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void setSortOption(ProductSortOption sortOption) {
    state = state.copyWith(sortOption: sortOption);
  }

  void setPriceRange(double min, double max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
  }

  void toggleInStockOnly() {
    state = state.copyWith(inStockOnly: !state.inStockOnly);
  }

  void toggleOnSaleOnly() {
    state = state.copyWith(onSaleOnly: !state.onSaleOnly);
  }

  void reset() {
    state = const FilterState();
  }
}

final filterNotifierProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

// Derived Provider: Filtered & Sorted Products
final filteredProductsProvider =
    Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  final asyncProducts = ref.watch(productsFutureProvider);
  final filter = ref.watch(filterNotifierProvider);

  return asyncProducts.whenData((products) {
    var list = products.where((product) {
      // Search filter
      if (filter.searchQuery.isNotEmpty) {
        final query = filter.searchQuery.toLowerCase();
        final matchesTitle = product.title.toLowerCase().contains(query);
        final matchesCategory = product.category.toLowerCase().contains(query);
        final matchesDesc = product.description.toLowerCase().contains(query);
        if (!matchesTitle && !matchesCategory && !matchesDesc) {
          return false;
        }
      }

      // Category filter
      if (filter.selectedCategory != 'Tous' &&
          product.category != filter.selectedCategory) {
        return false;
      }

      // Price filter
      if (product.price < filter.minPrice || product.price > filter.maxPrice) {
        return false;
      }

      // Stock filter
      if (filter.inStockOnly && !product.inStock) {
        return false;
      }

      // Discount filter
      if (filter.onSaleOnly && !product.hasDiscount) {
        return false;
      }

      return true;
    }).toList();

    // Sorting
    switch (filter.sortOption) {
      case ProductSortOption.featured:
        list.sort((a, b) {
          if (a.isFeatured && !b.isFeatured) return -1;
          if (!a.isFeatured && b.isFeatured) return 1;
          return 0;
        });
        break;
      case ProductSortOption.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
        break;
      case ProductSortOption.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
        break;
      case ProductSortOption.ratingDesc:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ProductSortOption.nameAsc:
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return list;
  });
});

// ==========================================
// 4. Favorites StateNotifierProvider (with Local Persistence)
// ==========================================

class FavoritesNotifier extends StateNotifier<Set<String>> {
  final FavoritesStorage _storage;

  FavoritesNotifier(this._storage) : super({}) {
    _loadFavorites();
  }

  void _loadFavorites() {
    state = _storage.loadFavoriteIds();
  }

  Future<void> toggleFavorite(String productId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    state = updated;
    await _storage.saveFavoriteIds(updated);
  }

  bool isFavorite(String productId) => state.contains(productId);

  Future<void> clearAll() async {
    state = {};
    await _storage.clearFavorites();
  }
}

final favoritesNotifierProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>((ref) {
  final storage = ref.watch(favoritesStorageProvider);
  return FavoritesNotifier(storage);
});

// Derived Provider: Full Favorite Products list
final favoriteProductsProvider =
    Provider.autoDispose<AsyncValue<List<Product>>>((ref) {
  final asyncProducts = ref.watch(productsFutureProvider);
  final favoriteIds = ref.watch(favoritesNotifierProvider);

  return asyncProducts.whenData((products) {
    return products.where((p) => favoriteIds.contains(p.id)).toList();
  });
});

// ==========================================
// 5. Shopping Cart StateNotifierProvider
// ==========================================

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(
    Product product, {
    int quantity = 1,
    String? selectedColor,
    String? selectedSize,
  }) {
    final color = selectedColor ?? (product.availableColors.isNotEmpty ? product.availableColors.first : null);
    final size = selectedSize ?? (product.availableSizes.isNotEmpty ? product.availableSizes.first : null);
    final itemId = '${product.id}_${color ?? "default"}_${size ?? "default"}';

    final index = state.indexWhere((item) => item.id == itemId);

    if (index != -1) {
      final existing = state[index];
      final newQuantity = existing.quantity + quantity;
      final updatedList = List<CartItem>.from(state);
      updatedList[index] = existing.copyWith(quantity: newQuantity);
      state = updatedList;
    } else {
      final newItem = CartItem(
        id: itemId,
        product: product,
        quantity: quantity,
        selectedColor: color,
        selectedSize: size,
      );
      state = [...state, newItem];
    }
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(itemId);
      return;
    }

    state = [
      for (final item in state)
        if (item.id == itemId) item.copyWith(quantity: newQuantity) else item
    ];
  }

  void clearCart() {
    state = [];
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

// Derived Provider: Cart Summary Calculations
class CartSummary {
  final int totalItemCount;
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final double total;
  final String? promoCode;

  const CartSummary({
    required this.totalItemCount,
    required this.subtotal,
    required this.tax,
    required this.shipping,
    required this.discount,
    required this.total,
    this.promoCode,
  });
}

final promoCodeProvider = StateProvider<String?>((ref) => null);

final cartSummaryProvider = Provider<CartSummary>((ref) {
  final cartItems = ref.watch(cartNotifierProvider);
  final promoCode = ref.watch(promoCodeProvider);

  int totalCount = 0;
  double subtotal = 0.0;

  for (final item in cartItems) {
    totalCount += item.quantity;
    subtotal += item.totalPrice;
  }

  final tax = subtotal * 0.20; // 20% TVA
  final shipping = subtotal == 0.0 ? 0.0 : (subtotal > 100.0 ? 0.0 : 9.99);

  double discount = 0.0;
  if (promoCode != null && promoCode.toUpperCase() == 'RIVERPOD20') {
    discount = subtotal * 0.20; // 20% off
  } else if (promoCode != null && promoCode.toUpperCase() == 'WELCOME10') {
    discount = 10.0;
  }

  final total = (subtotal + tax + shipping - discount).clamp(0.0, double.infinity);

  return CartSummary(
    totalItemCount: totalCount,
    subtotal: subtotal,
    tax: tax,
    shipping: shipping,
    discount: discount,
    total: total,
    promoCode: promoCode,
  );
});

// ==========================================
// 6. Theme Mode StateNotifierProvider
// ==========================================

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system);

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// ==========================================
// 7. User Profile StateNotifierProvider (Mock)
// ==========================================

class UserProfileNotifier extends StateNotifier<UserProfile> {
  UserProfileNotifier()
      : super(
          UserProfile(
            name: 'Alexandre Martin',
            email: 'alexandre.martin@example.com',
            phone: '+33 6 12 34 56 78',
            avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
            tier: 'Membre VIP Gold',
            loyaltyPoints: 1450,
            walletBalance: 240.50,
            addresses: const [
              '14 Avenue des Champs-Élysées, 75008 Paris',
              '28 Rue de la République, 69002 Lyon',
            ],
            pastOrders: [
              OrderSummary(
                orderId: 'CMD-2026-9841',
                date: DateTime.now().subtract(const Duration(days: 3)),
                status: 'Livrée',
                itemsCount: 3,
                totalAmount: 329.89,
                deliveryAddress: '14 Avenue des Champs-Élysées, 75008 Paris',
              ),
              OrderSummary(
                orderId: 'CMD-2026-8712',
                date: DateTime.now().subtract(const Duration(days: 18)),
                status: 'Livrée',
                itemsCount: 1,
                totalAmount: 89.90,
                deliveryAddress: '14 Avenue des Champs-Élysées, 75008 Paris',
              ),
              OrderSummary(
                orderId: 'CMD-2026-7643',
                date: DateTime.now().subtract(const Duration(days: 45)),
                status: 'Livrée',
                itemsCount: 2,
                totalAmount: 169.50,
                deliveryAddress: '28 Rue de la République, 69002 Lyon',
              ),
            ],
          ),
        );

  void addOrder(OrderSummary order) {
    state = state.copyWith(
      pastOrders: [order, ...state.pastOrders],
      loyaltyPoints: state.loyaltyPoints + (order.totalAmount / 2).round(),
    );
  }

  void addAddress(String address) {
    state = state.copyWith(addresses: [...state.addresses, address]);
  }
}

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  return UserProfileNotifier();
});
