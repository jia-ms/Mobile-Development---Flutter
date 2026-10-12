import 'package:cloud_firestore/cloud_firestore.dart';

const orderStatuses = [
  'placed',
  'confirmed',
  'packed',
  'shipped',
  'delivered',
  'cancelled'
];

class OrderItem {
  final String productId, name;
  final num price;
  final int qty;

  const OrderItem(
      {required this.productId,
      required this.name,
      required this.price,
      required this.qty});

  factory OrderItem.fromMap(Map<String, dynamic> d) => OrderItem(
        productId: d['productId'] ?? '',
        name: d['name'] ?? '',
        price: d['price'] ?? 0,
        qty: (d['qty'] ?? 1).toInt(),
      );

  Map<String, dynamic> toMap() =>
      {'productId': productId, 'name': name, 'price': price, 'qty': qty};
}

class StoreOrder {
  final String id, userId, status, name, phone, address, notes;
  final List<OrderItem> items;
  final num total;
  final DateTime? createdAt;

  const StoreOrder({
    required this.id,
    required this.userId,
    required this.status,
    required this.name,
    required this.phone,
    required this.address,
    required this.notes,
    required this.items,
    required this.total,
    required this.createdAt,
  });

  factory StoreOrder.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return StoreOrder(
      id: doc.id,
      userId: d['userId'] ?? '',
      status: d['status'] ?? 'placed',
      name: d['name'] ?? '',
      phone: d['phone'] ?? '',
      address: d['address'] ?? '',
      notes: d['notes'] ?? '',
      items: (d['items'] as List? ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e)))
          .toList(),
      total: d['total'] ?? 0,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
