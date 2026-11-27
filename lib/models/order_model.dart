import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatus {
  static const pending = 'pending';
  static const preparing = 'preparing';
  static const ready = 'ready';
  static const completed = 'completed';

  static const active = [pending, preparing, ready];

  static String? next(String current) {
    switch (current) {
      case pending:
        return preparing;
      case preparing:
        return ready;
      case ready:
        return completed;
      default:
        return null;
    }
  }
}

class OrderItem {
  final String itemId;
  final String name;
  final double price;
  final int qty;

  const OrderItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.qty,
  });

  factory OrderItem.fromMap(Map<String, dynamic> m) => OrderItem(
        itemId: m['itemId'] ?? '',
        name: m['name'] ?? '',
        price: (m['price'] ?? 0).toDouble(),
        qty: (m['qty'] ?? 1) is int ? m['qty'] as int : (m['qty'] as num).toInt(),
      );

  Map<String, dynamic> toMap() =>
      {'itemId': itemId, 'name': name, 'price': price, 'qty': qty};
}

class OrderModel {
  final String id;
  final String userEmail;
  final List<OrderItem> items;
  final double total;
  final String pickupNote;
  final String status;
  final DateTime? createdAt;

  const OrderModel({
    required this.id,
    required this.userEmail,
    required this.items,
    required this.total,
    required this.pickupNote,
    required this.status,
    required this.createdAt,
  });

  String get shortId => id.length > 5 ? id.substring(0, 5).toUpperCase() : id;

  factory OrderModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return OrderModel(
      id: doc.id,
      userEmail: d['userEmail'] ?? '',
      items: ((d['items'] as List?) ?? [])
          .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
      total: (d['total'] ?? 0).toDouble(),
      pickupNote: d['pickupNote'] ?? '',
      status: d['status'] ?? OrderStatus.pending,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
