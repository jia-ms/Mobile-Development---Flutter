import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/store_order.dart';

class OrderRepository {
  OrderRepository([FirebaseFirestore? db])
      : _db = db ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  /// Trial payment modes. Must match PaymentMethod.name in
  /// payment_method_selector.dart.
  static const supportedPaymentMethods = {'cod', 'upi', 'card'};

  Future<String> placeOrder({
    required String userId,
    required List<OrderItem> items,
    required num total,
    required String name,
    required String phone,
    required String address,
    required String notes,
    String paymentMethod = 'cod',
  }) async {
    if (!supportedPaymentMethods.contains(paymentMethod)) {
      throw ArgumentError('Unsupported payment method: $paymentMethod');
    }

    // ID is generated client-side, so we have it even before the server replies.
    final ref = _db.collection('orders').doc();
    await ref.set({
      'userId': userId,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'status': 'placed',
      'paymentMethod': paymentMethod,
      // Demo: UPI/Card are "paid" by the simulated payment step;
      // COD is collected on delivery.
      'paymentStatus': paymentMethod == 'cod' ? 'pending' : 'paid',
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    }).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception(
          'Firestore did not respond in 15s. Check that a Firestore database '
              'exists in the Firebase console and that you are online.'),
    );

    return ref.id;
  }

  /// Sorted client-side so no composite index is needed.
  Stream<List<StoreOrder>> userOrders(String uid) => _db
      .collection('orders')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) {
    final list = s.docs.map(StoreOrder.fromDoc).toList();
    final now = DateTime.now();
    list.sort((a, b) =>
        (b.createdAt ?? now).compareTo(a.createdAt ?? now));
    return list;
  });

  Stream<List<StoreOrder>> allOrders() => _db
      .collection('orders')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(StoreOrder.fromDoc).toList());

  Future<void> updateStatus(String orderId, String status) =>
      _db.doc('orders/$orderId').update({'status': status});

  /// Lets admin mark a COD order as paid once cash is collected.
  Future<void> updatePaymentStatus(String orderId, String paymentStatus) =>
      _db.doc('orders/$orderId').update({'paymentStatus': paymentStatus});
}