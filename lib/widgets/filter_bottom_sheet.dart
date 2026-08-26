import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/filter_state.dart';
import '../../providers/providers.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late ProductSortOption _selectedSort;
  late RangeValues _priceRange;
  late bool _inStockOnly;
  late bool _onSaleOnly;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    final current = ref.read(filterNotifierProvider);
    _selectedSort = current.sortOption;
    _priceRange = RangeValues(current.minPrice, current.maxPrice);
    _inStockOnly = current.inStockOnly;
    _onSaleOnly = current.onSaleOnly;
    _selectedCategory = current.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtres & Tri',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedSort = ProductSortOption.featured;
                      _priceRange = const RangeValues(0.0, 1000.0);
                      _inStockOnly = false;
                      _onSaleOnly = false;
                      _selectedCategory = 'Tous';
                    });
                  },
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
            const Divider(height: 24),

            // Tri par
            const Text(
              'Trier par',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ProductSortOption.values.map((option) {
                final isSelected = _selectedSort == option;
                return ChoiceChip(
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (val) {
                    if (val) setState(() => _selectedSort = option);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Catégories
            const Text(
              'Catégorie',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            categoriesAsync.when(
              data: (categories) => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedCategory = cat);
                    },
                  );
                }).toList(),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),

            // Intervalle de Prix
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tranche de prix',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_priceRange.start.round()} € - ${_priceRange.end.round()} €',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
            RangeSlider(
              values: _priceRange,
              min: 0.0,
              max: 1000.0,
              divisions: 20,
              labels: RangeLabels(
                '${_priceRange.start.round()} €',
                '${_priceRange.end.round()} €',
              ),
              onChanged: (values) {
                setState(() => _priceRange = values);
              },
            ),
            const SizedBox(height: 16),

            // Toggles
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('En stock uniquement'),
              subtitle: const Text('Masquer les produits épuisés', style: TextStyle(fontSize: 12)),
              value: _inStockOnly,
              onChanged: (val) => setState(() => _inStockOnly = val),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('En promotion uniquement'),
              subtitle: const Text('Afficher les réductions', style: TextStyle(fontSize: 12)),
              value: _onSaleOnly,
              onChanged: (val) => setState(() => _onSaleOnly = val),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final notifier = ref.read(filterNotifierProvider.notifier);
                  notifier.setSortOption(_selectedSort);
                  notifier.setCategory(_selectedCategory);
                  notifier.setPriceRange(_priceRange.start, _priceRange.end);
                  if (ref.read(filterNotifierProvider).inStockOnly != _inStockOnly) {
                    notifier.toggleInStockOnly();
                  }
                  if (ref.read(filterNotifierProvider).onSaleOnly != _onSaleOnly) {
                    notifier.toggleOnSaleOnly();
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Appliquer les filtres'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
