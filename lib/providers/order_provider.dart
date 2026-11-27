import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/cart_line.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider.student(this._fs, String uid, this._email) : _uid = uid {
    _listen(_fs.ordersForUser(uid));
  }

  OrderProvider.staff(this._fs)
      : _uid = null,
        _email = null {
    _listen(_fs.activeOrders());
  }

  final FirestoreService _fs;
  final String? _uid;
  final String? _email;
  StreamSubscription<List<OrderModel>>? _sub;

  List<OrderModel> orders = [];
  bool loading = true;
  String? error;

  void _listen(Stream<List<OrderModel>> stream) {
    _sub = stream.listen(
      (data) {
        orders = data;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (e) {
        error = e.toString();
        loading = false;
        notifyListeners();
      },
    );
  }

  void refresh() {
    _sub?.cancel();
    loading = true;
    error = null;
    notifyListeners();
    _listen(
      _uid == null ? _fs.activeOrders() : _fs.ordersForUser(_uid),
    );
  }

  Future<void> placeOrder({
    required List<CartLine> lines,
    required double total,
    required String note,
  }) {
    return _fs.placeOrder(
      userId: _uid!,
      userEmail: _email ?? '',
      items: lines
          .map((l) => OrderItem(
                itemId: l.item.id,
                name: l.item.name,
                price: l.item.price,
                qty: l.qty,
              ))
          .toList(),
      total: total,
      pickupNote: note,
    );
  }

  Future<void> advance(OrderModel order) async {
    final next = OrderStatus.next(order.status);
    if (next != null) await _fs.updateStatus(order.id, next);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
