class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String category;
  final String imageUrl;
  final List<String> galleryImages;
  final bool inStock;
  final int stockCount;
  final List<String> availableColors;
  final List<String> availableSizes;
  final Map<String, String> specifications;
  final bool isFeatured;

  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.category,
    required this.imageUrl,
    required this.galleryImages,
    required this.inStock,
    required this.stockCount,
    this.availableColors = const [],
    this.availableSizes = const [],
    this.specifications = const {},
    this.isFeatured = false,
  });

  // Alias for compatibility
  String get name => title;
  String get image => imageUrl;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  int get discountPercentage {
    if (!hasDiscount) return 0;
    return (((originalPrice! - price) / originalPrice!) * 100).round();
  }

  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    double? originalPrice,
    double? rating,
    int? reviewCount,
    String? category,
    String? imageUrl,
    List<String>? galleryImages,
    bool? inStock,
    int? stockCount,
    List<String>? availableColors,
    List<String>? availableSizes,
    Map<String, String>? specifications,
    bool? isFeatured,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      galleryImages: galleryImages ?? this.galleryImages,
      inStock: inStock ?? this.inStock,
      stockCount: stockCount ?? this.stockCount,
      availableColors: availableColors ?? this.availableColors,
      availableSizes: availableSizes ?? this.availableSizes,
      specifications: specifications ?? this.specifications,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'name': title,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'rating': rating,
      'reviewCount': reviewCount,
      'category': category,
      'imageUrl': imageUrl,
      'image': imageUrl,
      'galleryImages': galleryImages,
      'inStock': inStock,
      'stockCount': stockCount,
      'availableColors': availableColors,
      'availableSizes': availableSizes,
      'specifications': specifications,
      'isFeatured': isFeatured,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) => Product.fromMap(json);

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? map['name'] ?? '').toString(),
      description: (map['description'] ?? '').toString(),
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: map['originalPrice'] != null
          ? (map['originalPrice'] as num).toDouble()
          : null,
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (map['reviewCount'] ?? map['rating_count'] as num?)?.toInt() ?? 0,
      category: (map['category'] ?? 'Général').toString(),
      imageUrl: (map['imageUrl'] ?? map['image'] ?? '').toString(),
      galleryImages: map['galleryImages'] != null
          ? List<String>.from(map['galleryImages'])
          : (map['imageUrl'] != null ? [map['imageUrl'].toString()] : []),
      inStock: map['inStock'] as bool? ?? (map['stock'] != null ? (map['stock'] as num) > 0 : true),
      stockCount: (map['stockCount'] ?? map['stock'] as num?)?.toInt() ?? 10,
      availableColors: map['availableColors'] != null
          ? List<String>.from(map['availableColors'])
          : const [],
      availableSizes: map['availableSizes'] != null
          ? List<String>.from(map['availableSizes'])
          : const [],
      specifications: map['specifications'] != null
          ? Map<String, String>.from(map['specifications'])
          : const {},
      isFeatured: map['isFeatured'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Product && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
