import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid, name, email, phone, role;

  const AppUser(
      {required this.uid,
      required this.name,
      required this.email,
      required this.phone,
      required this.role});

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      name: d['name'] ?? '',
      email: d['email'] ?? '',
      phone: d['phone'] ?? '',
      role: d['role'] ?? 'customer',
    );
  }
}
