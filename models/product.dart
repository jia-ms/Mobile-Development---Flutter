import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id, name, description, weight;
  final List<String> categoryIds; // a product can live in several categories
  final List<String> images; // first one is the main photo
  final num price;
  final bool inStock, featured, isVeg;
  final double rating; // 0 = not rated yet
  final int sortOrder;

  const Product({
    required this.id,
    required this.name,
    this.description = '',
    this.weight = '',
    this.categoryIds = const [],
    this.images = const [],
    required this.price,
    this.inStock = true,
    this.featured = false,
    this.isVeg = true,
    this.rating = 0,
    this.sortOrder = 0,
  });

  String get imageUrl => images.isEmpty ? '' : images.first;
  String get displayName => weight.isEmpty ? name : '$name $weight';

  factory Product.fromMap(Map<String, dynamic> d) {
    return Product(
      id: d['id']?.toString() ?? '',
      name: d['name']?.toString() ?? '',
      description: d['description']?.toString() ?? '',
      weight: d['weight']?.toString() ?? '',
      categoryIds: List<String>.from(d['categoryIds'] ?? []),
      images: List<String>.from(d['images'] ?? []),
      price: d['price'] as num? ?? 0,
      inStock: d['inStock'] as bool? ?? true,
      featured: d['featured'] as bool? ?? false,
      isVeg: d['isVeg'] as bool? ?? true,
      rating: (d['rating'] as num?)?.toDouble() ?? 0,
      sortOrder: (d['sortOrder'] as num?)?.toInt() ?? 0,
    );
  }

  factory Product.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    final legacyCategory = d['categoryId'];
    final legacyImage = d['imageUrl'];
    return Product(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'] ?? '',
      weight: d['weight'] ?? '',
      categoryIds: List<String>.from(d['categoryIds'] ??
          (legacyCategory is String ? [legacyCategory] : const [])),
      images: List<String>.from(d['images'] ??
          (legacyImage is String && legacyImage.isNotEmpty
              ? [legacyImage]
              : const [])),
      price: d['price'] ?? 0,
      inStock: d['inStock'] ?? true,
      featured: d['featured'] ?? false,
      isVeg: d['isVeg'] ?? true,
      rating: (d['rating'] ?? 0).toDouble(),
      sortOrder: (d['sortOrder'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'weight': weight,
    'categoryIds': categoryIds,
    'images': images,
    'price': price,
    'inStock': inStock,
    'featured': featured,
    'isVeg': isVeg,
    'rating': rating,
    'sortOrder': sortOrder,
  };
}