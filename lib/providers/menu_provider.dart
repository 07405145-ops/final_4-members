import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/menu_item.dart';
import '../services/firestore_service.dart';

/// Holds the live menu list. Used by students (browse) and staff (toggle).
class MenuProvider extends ChangeNotifier {
  MenuProvider(this._fs) {
    _sub = _fs.menuStream().listen(
      (data) {
        items = data;
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

  final FirestoreService _fs;
  late final StreamSubscription<List<MenuItem>> _sub;

  List<MenuItem> items = [];
  bool loading = true;
  String? error;

  Future<void> setAvailability(String id, bool value) =>
      _fs.setAvailability(id, value);

  Future<void> seedMenu() => _fs.seedMenu();

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
