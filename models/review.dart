import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String id, name, text, avatarUrl;
  final int rating;
  final bool approved;

  const Review(
      {required this.id,
        required this.name,
        required this.text,
        this.avatarUrl = '',
        required this.rating,
        required this.approved});

  factory Review.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return Review(
      id: doc.id,
      name: d['name'] ?? '',
      text: d['text'] ?? '',
      avatarUrl: d['avatarUrl'] ?? '',
      rating: (d['rating'] ?? 5).toInt(),
      approved: d['approved'] ?? false,
    );
  }
}