class OrderSummary {
  final String orderId;
  final DateTime date;
  final String status;
  final int itemsCount;
  final double totalAmount;
  final String deliveryAddress;

  const OrderSummary({
    required this.orderId,
    required this.date,
    required this.status,
    required this.itemsCount,
    required this.totalAmount,
    required this.deliveryAddress,
  });
}

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String tier;
  final int loyaltyPoints;
  final double walletBalance;
  final List<String> addresses;
  final List<OrderSummary> pastOrders;

  const UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.avatarUrl,
    required this.tier,
    required this.loyaltyPoints,
    required this.walletBalance,
    required this.addresses,
    required this.pastOrders,
  });

  UserProfile copyWith({
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? tier,
    int? loyaltyPoints,
    double? walletBalance,
    List<String>? addresses,
    List<OrderSummary>? pastOrders,
  }) {
    return UserProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      tier: tier ?? this.tier,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      walletBalance: walletBalance ?? this.walletBalance,
      addresses: addresses ?? this.addresses,
      pastOrders: pastOrders ?? this.pastOrders,
    );
  }
}
