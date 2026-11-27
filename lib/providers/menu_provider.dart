import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/menu_item.dart';
import '../services/firestore_service.dart';

class MenuProvider extends ChangeNotifier {
  MenuProvider(this._fs) {
    _listen();
  }

  final FirestoreService _fs;
  StreamSubscription<List<MenuItem>>? _sub;

  List<MenuItem> items = [];
  bool loading = true;
  String? error;

  void _listen() {
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

  void refresh() {
    _sub?.cancel();
    loading = true;
    error = null;
    notifyListeners();
    _listen();
  }

  Future<void> setAvailability(String id, bool value) async {
    try {
      await _fs.setAvailability(id, value);
      error = null;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> seedMenu() => _fs.seedMenu();

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
