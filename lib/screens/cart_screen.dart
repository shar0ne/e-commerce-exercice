import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_profile.dart';
import '../../providers/providers.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  bool _isApplyingPromo = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _showCheckoutSuccessModal(BuildContext context, double totalAmount, int itemsCount) {
    final orderId = 'CMD-2026-${1000 + DateTime.now().millisecond}';
    final user = ref.read(userProfileProvider);
    final deliveryAddress = user.addresses.isNotEmpty
        ? user.addresses.first
        : '14 Avenue des Champs-Élysées, 75008 Paris';

    // Add order to profile history
    ref.read(userProfileProvider.notifier).addOrder(
          OrderSummary(
            orderId: orderId,
            date: DateTime.now(),
            status: 'En préparation',
            itemsCount: itemsCount,
            totalAmount: totalAmount,
            deliveryAddress: deliveryAddress,
          ),
        );

    // Clear cart and promo code
    ref.read(cartNotifierProvider.notifier).clearCart();
    ref.read(promoCodeProvider.notifier).state = null;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(ctx).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: 18),
            const Text(
              'Commande Confirmée !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Merci pour votre achat. Votre commande #$orderId a été enregistrée avec succès.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(ctx).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Montant prélevé:', style: TextStyle(fontWeight: FontWeight.w500)),
                  Text(
                    '${totalAmount.toStringAsFixed(2)} €',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Continuer mes achats'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartNotifierProvider);
    final summary = ref.watch(cartSummaryProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Vider le panier',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Vider le panier ?'),
                    content: const Text(
                      'Êtes-vous sûr de vouloir supprimer tous les articles de votre panier ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Annuler'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                        ),
                        onPressed: () {
                          ref.read(cartNotifierProvider.notifier).clearCart();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Vider'),
                      ),
                    ],
                  ),
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        size: 72,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Votre panier est vide',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Découvrez nos nouveautés et ajoutez vos coups de cœur à votre panier.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          : CustomScrollView(
              slivers: [
                // Free Shipping Progress indicator
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: summary.subtotal >= 100
                          ? const Color(0xFF10B981).withAlpha(20)
                          : theme.colorScheme.primary.withAlpha(15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          summary.subtotal >= 100
                              ? Icons.local_shipping_rounded
                              : Icons.info_outline_rounded,
                          color: summary.subtotal >= 100
                              ? const Color(0xFF10B981)
                              : theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            summary.subtotal >= 100
                                ? 'Félicitations ! Livraison standard gratuite offerte.'
                                : 'Plus que ${(100 - summary.subtotal).toStringAsFixed(2)} € pour la livraison gratuite !',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: summary.subtotal >= 100
                                  ? const Color(0xFF10B981)
                                  : theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cart Items List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = cartItems[index];
                        return Dismissible(
                          key: ValueKey(item.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                          ),
                          onDismissed: (_) {
                            ref.read(cartNotifierProvider.notifier).removeItem(item.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.cardColor,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Thumbnail
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    item.product.imageUrl,
                                    width: 76,
                                    height: 76,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 76,
                                      height: 76,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image_rounded, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),

                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      if (item.selectedColor != null || item.selectedSize != null)
                                        Text(
                                          '${item.selectedColor ?? ""} ${item.selectedSize != null ? "• ${item.selectedSize}" : ""}',
                                          style: TextStyle(
                                            color: Colors.grey.shade500,
                                            fontSize: 12,
                                          ),
                                        ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${item.product.price.toStringAsFixed(2)} €',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Stepper
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          ref
                                              .read(cartNotifierProvider.notifier)
                                              .updateQuantity(item.id, item.quantity - 1);
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Icon(Icons.remove_rounded, size: 16),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          ref
                                              .read(cartNotifierProvider.notifier)
                                              .updateQuantity(item.id, item.quantity + 1);
                                        },
                                        borderRadius: BorderRadius.circular(10),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6.0),
                                          child: Icon(Icons.add_rounded, size: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: cartItems.length,
                    ),
                  ),
                ),

                // Promo code section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              hintText: 'Code promo (ex: RIVERPOD20)',
                              prefixIcon: Icon(Icons.confirmation_number_outlined, size: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _isApplyingPromo
                              ? null
                              : () async {
                                  final code = _promoController.text.trim();
                                  if (code.isEmpty) return;
                                  final messenger = ScaffoldMessenger.of(context);
                                  setState(() => _isApplyingPromo = true);

                                  await Future.delayed(const Duration(milliseconds: 300));
                                  if (!mounted) return;

                                  setState(() => _isApplyingPromo = false);
                                  if (code.toUpperCase() == 'RIVERPOD20' ||
                                      code.toUpperCase() == 'WELCOME10') {
                                    ref.read(promoCodeProvider.notifier).state = code;
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Code promo appliqué avec succès !'),
                                        backgroundColor: Color(0xFF10B981),
                                      ),
                                    );
                                  } else {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text('Code promo invalide.'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                },
                          child: _isApplyingPromo
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Appliquer'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Order summary breakdown
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Récapitulatif de la commande',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 14),
                        _buildSummaryRow('Sous-total', '${summary.subtotal.toStringAsFixed(2)} €'),
                        const SizedBox(height: 8),
                        _buildSummaryRow('TVA estimée (20%)', '${summary.tax.toStringAsFixed(2)} €'),
                        const SizedBox(height: 8),
                        _buildSummaryRow(
                          'Frais de livraison',
                          summary.shipping == 0.0 ? 'Gratuit' : '${summary.shipping.toStringAsFixed(2)} €',
                          valueColor: summary.shipping == 0.0 ? const Color(0xFF10B981) : null,
                        ),
                        if (summary.discount > 0) ...[
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Réduction (${summary.promoCode})',
                            '- ${summary.discount.toStringAsFixed(2)} €',
                            valueColor: const Color(0xFF10B981),
                          ),
                        ],
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Total TTC',
                          '${summary.total.toStringAsFixed(2)} €',
                          isBold: true,
                          fontSize: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
      bottomSheet: cartItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: theme.cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? 50 : 15),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _showCheckoutSuccessModal(context, summary.total, summary.totalItemCount);
                    },
                    child: Text('Commander (${summary.total.toStringAsFixed(2)} €)'),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    double fontSize = 14,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? null : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
