import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/menu_item.dart';
import '../models/order_model.dart';

/// All Firestore reads/writes for menu and orders live here.
/// Screens never touch Firestore directly.
class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ---------- MENU ----------
  Stream<List<MenuItem>> menuStream() => _db
      .collection('menu_items')
      .orderBy('name')
      .snapshots()
      .map((s) => s.docs.map(MenuItem.fromDoc).toList());

  Future<void> setAvailability(String id, bool available) =>
      _db.collection('menu_items').doc(id).update({'available': available});

  /// Fills an empty menu with sample data (staff only, for testing).
  Future<void> seedMenu() async {
    const samples = [
      {'name': 'Chicken Adobo w/ Rice', 'category': 'Meals', 'price': 65},
      {'name': 'Pork Sinigang w/ Rice', 'category': 'Meals', 'price': 70},
      {'name': 'Pancit Canton', 'category': 'Snacks', 'price': 30},
      {'name': 'Siomai (4pcs)', 'category': 'Snacks', 'price': 35},
      {'name': 'Iced Tea', 'category': 'Drinks', 'price': 20},
      {'name': 'Bottled Water', 'category': 'Drinks', 'price': 15},
    ];
    final batch = _db.batch(); // all writes succeed or none do
    for (final s in samples) {
      batch.set(_db.collection('menu_items').doc(), {...s, 'available': true});
    }
    await batch.commit();
  }

  // ---------- ORDERS ----------
  /// One order = one document. Name and price are copied into the order so
  /// old orders stay correct if the menu price changes later.
  Future<void> placeOrder({
    required String userId,
    required String userEmail,
    required List<OrderItem> items,
    required double total,
    required String pickupNote,
  }) {
    return _db.collection('orders').add({
      'userId': userId,
      'userEmail': userEmail,
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'pickupNote': pickupNote,
      'status': OrderStatus.pending,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<OrderModel>> ordersForUser(String uid) => _db
      .collection('orders')
      .where('userId', isEqualTo: uid)
      .snapshots()
      .map((s) => _sortNewest(s.docs.map(OrderModel.fromDoc).toList()));

  Stream<List<OrderModel>> activeOrders() => _db
      .collection('orders')
      .where('status', whereIn: OrderStatus.active)
      .snapshots()
      .map((s) => _sortNewest(s.docs.map(OrderModel.fromDoc).toList()));

  Future<void> updateStatus(String orderId, String status) =>
      _db.collection('orders').doc(orderId).update({'status': status});

  // Sorted in Dart so we don't need a Firestore composite index.
  // createdAt is null for a split second on a just-created order -> newest.
  List<OrderModel> _sortNewest(List<OrderModel> list) {
    final now = DateTime.now();
    list.sort((a, b) => (b.createdAt ?? now).compareTo(a.createdAt ?? now));
    return list;
  }
}
