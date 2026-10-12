import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/store_settings.dart';

class CatalogRepository {
  CatalogRepository([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  // ---- reads (public) ----
  Stream<StoreSettings?> settings() => _db
      .doc('settings/store')
      .snapshots()
      .map((s) => s.exists ? StoreSettings.fromMap(s.data()!) : null);

  Stream<List<ProductCategory>> categories() => _db
      .collection('categories')
      .orderBy('order')
      .snapshots()
      .map((s) => s.docs.map(ProductCategory.fromDoc).toList());


  Stream<List<Product>> products() async* {
    final jsonString = await rootBundle.loadString(
      'assets/seed_data.json',
    );

    final Map<String, dynamic> data = jsonDecode(jsonString);

    final rawProducts = data['products'] as List<dynamic>;

    final list = rawProducts
        .map(
          (item) => Product.fromMap(
        Map<String, dynamic>.from(item as Map),
      ),
    )
        .toList();

    list.sort((a, b) {
      final c = a.sortOrder.compareTo(b.sortOrder);
      return c != 0 ? c : a.name.compareTo(b.name);
    });

    yield list;
  }


  Stream<List<Review>> reviews() => _db
      .collection('reviews')
      .where('approved', isEqualTo: true)
      .snapshots()
      .map((s) => s.docs.map(Review.fromDoc).toList());

  // ---- writes (admin only, enforced by Firestore rules) ----
  Future<void> saveProduct(Product p) {
    final col = _db.collection('products');
    final ref = p.id.isEmpty ? col.doc() : col.doc(p.id);
    return ref.set(
        {...p.toMap(), 'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true));
  }

  Future<void> setInStock(String id, bool value) =>
      _db.doc('products/$id').update({'inStock': value});

  Future<void> deleteProduct(String id) => _db.doc('products/$id').delete();

  Future<void> saveCategory(ProductCategory c) {
    final col = _db.collection('categories');
    final ref = c.id.isEmpty ? col.doc() : col.doc(c.id);
    return ref.set(c.toMap(), SetOptions(merge: true));
  }

  Future<void> deleteCategory(String id) => _db.doc('categories/$id').delete();

  Future<void> saveSettings(StoreSettings s) =>
      _db.doc('settings/store').set(s.toMap(), SetOptions(merge: true));
}