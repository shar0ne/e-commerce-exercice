enum ProductSortOption {
  featured('Populaire'),
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  ratingDesc('Meilleures notes'),
  nameAsc('Nom A-Z');

  final String label;
  const ProductSortOption(this.label);
}

class FilterState {
  final String searchQuery;
  final String selectedCategory;
  final ProductSortOption sortOption;
  final double minPrice;
  final double maxPrice;
  final bool inStockOnly;
  final bool onSaleOnly;

  const FilterState({
    this.searchQuery = '',
    this.selectedCategory = 'Tous',
    this.sortOption = ProductSortOption.featured,
    this.minPrice = 0.0,
    this.maxPrice = 1000.0,
    this.inStockOnly = false,
    this.onSaleOnly = false,
  });

  bool get hasActiveFilters =>
      searchQuery.isNotEmpty ||
      selectedCategory != 'Tous' ||
      sortOption != ProductSortOption.featured ||
      minPrice > 0 ||
      maxPrice < 1000 ||
      inStockOnly ||
      onSaleOnly;

  FilterState copyWith({
    String? searchQuery,
    String? selectedCategory,
    ProductSortOption? sortOption,
    double? minPrice,
    double? maxPrice,
    bool? inStockOnly,
    bool? onSaleOnly,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortOption: sortOption ?? this.sortOption,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      onSaleOnly: onSaleOnly ?? this.onSaleOnly,
    );
  }

  FilterState reset() {
    return const FilterState();
  }
}
