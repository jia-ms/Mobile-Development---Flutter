import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart' show rootBundle;

/// One-click import of assets/seed/seed_data.json into Firestore.
/// Admin only (Firestore rules reject it for everyone else).
/// The JSON is data, not code: edit it, or manage everything from the admin UI.
class SeedService {
  static Future<void> run([FirebaseFirestore? firestore]) async {
    final db = firestore ?? FirebaseFirestore.instance;
    final raw = await rootBundle.loadString('assets/seed/seed_data.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final batch = db.batch();

    batch.set(db.doc('settings/store'),
        Map<String, dynamic>.from(data['settings'] as Map));

    void addAll(String collection) {
      for (final item in data[collection] as List) {
        final m = Map<String, dynamic>.from(item as Map);
        final id = m.remove('id') as String;
        batch.set(db.collection(collection).doc(id), m);
      }
    }

    addAll('categories');
    addAll('products');
    addAll('reviews');
    await batch.commit();
  }
}
