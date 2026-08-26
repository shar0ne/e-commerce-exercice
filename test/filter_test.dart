import 'package:flutter_test/flutter_test.dart';
import 'package:ecommerce_riverpod/models/filter_state.dart';
import 'package:ecommerce_riverpod/providers/providers.dart';

void main() {
  test('FilterNotifier properly modifies filter state', () {
    final notifier = FilterNotifier();

    expect(notifier.state.searchQuery, '');
    expect(notifier.state.selectedCategory, 'Tous');
    expect(notifier.state.sortOption, ProductSortOption.featured);

    notifier.setSearchQuery('laptop');
    expect(notifier.state.searchQuery, 'laptop');

    notifier.setCategory('Informatique');
    expect(notifier.state.selectedCategory, 'Informatique');

    notifier.setSortOption(ProductSortOption.priceAsc);
    expect(notifier.state.sortOption, ProductSortOption.priceAsc);

    notifier.setPriceRange(100, 500);
    expect(notifier.state.minPrice, 100);
    expect(notifier.state.maxPrice, 500);

    notifier.toggleInStockOnly();
    expect(notifier.state.inStockOnly, isTrue);

    notifier.toggleOnSaleOnly();
    expect(notifier.state.onSaleOnly, isTrue);

    notifier.reset();
    expect(notifier.state.searchQuery, '');
    expect(notifier.state.selectedCategory, 'Tous');
  });
}
