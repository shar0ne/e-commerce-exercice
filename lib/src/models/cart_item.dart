import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final int quantity;
  final String? selectedColor;
  final String? selectedSize;

  const CartItem({
    required this.id,
    required this.product,
    this.quantity = 1,
    this.selectedColor,
    this.selectedSize,
  });

  double get unitPrice => product.price;
  double get totalPrice => product.price * quantity;

  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    String? selectedColor,
    String? selectedSize,
  }) {
    return CartItem(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      selectedColor: selectedColor ?? this.selectedColor,
      selectedSize: selectedSize ?? this.selectedSize,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product': product.toMap(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem.fromMap(json);

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'] as String,
      product: Product.fromMap(map['product'] as Map<String, dynamic>),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      selectedColor: map['selectedColor'] as String?,
      selectedSize: map['selectedSize'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItem && runtimeType == other.runtimeType && id == other.id && quantity == other.quantity;

  @override
  int get hashCode => Object.hash(id, quantity);
}
