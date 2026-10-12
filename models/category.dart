import 'package:cloud_firestore/cloud_firestore.dart';

class ProductCategory {
  final String id, name, imageUrl;
  final int order;
  final bool active;

  const ProductCategory(
      {required this.id,
        required this.name,
        this.imageUrl = '',
        this.order = 0,
        this.active = true});

  factory ProductCategory.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return ProductCategory(
      id: doc.id,
      name: d['name'] ?? '',
      imageUrl: d['imageUrl'] ?? '',
      order: (d['order'] ?? 0).toInt(),
      active: d['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() =>
      {'name': name, 'imageUrl': imageUrl, 'order': order, 'active': active};
}