import 'package:flutter/foundation.dart';

import '../models/cart_line.dart';
import '../models/menu_item.dart';

/// In-memory cart (not saved to Firestore until the order is placed).
class CartProvider extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};

  List<CartLine> get lines => _lines.values.toList();
  int get count => _lines.values.fold(0, (sum, l) => sum + l.qty);
  double get total => _lines.values.fold(0.0, (sum, l) => sum + l.subtotal);
  bool get isEmpty => _lines.isEmpty;

  void add(MenuItem item) {
    final existing = _lines[item.id];
    if (existing == null) {
      _lines[item.id] = CartLine(item, 1);
    } else {
      existing.qty += 1;
    }
    notifyListeners();
  }

  void remove(MenuItem item) {
    final line = _lines[item.id];
    if (line == null) return;
    line.qty -= 1;
    if (line.qty <= 0) _lines.remove(item.id);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }
}
