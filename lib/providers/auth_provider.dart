import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

enum AuthStatus { loading, signedOut, student, staff }

/// State layer for login state + role. UI watches this; it calls AuthService.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _sub = _service.authChanges.listen(_onAuthChanged);
  }

  final AuthService _service;
  late final StreamSubscription<User?> _sub;

  AuthStatus status = AuthStatus.loading;
  User? user;
  bool busy = false; // true while a login/register call is running
  String? error;

  Future<void> _onAuthChanged(User? u) async {
    user = u;
    if (u == null) {
      status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }
    status = AuthStatus.loading;
    notifyListeners();
    String role;
    try {
      role = await _service.getRole(u.uid);
    } catch (_) {
      role = 'student'; // safest default if the role lookup fails
    }
    if (user?.uid != u.uid) return; // user changed while we were waiting
    status = role == 'staff' ? AuthStatus.staff : AuthStatus.student;
    notifyListeners();
  }

  Future<void> login(String email, String password) =>
      _run(() => _service.login(email, password));

  Future<void> register(String name, String email, String password) =>
      _run(() => _service.register(name, email, password));

  Future<void> logout() => _service.logout();

  void clearError() {
    error = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
    } on FirebaseAuthException catch (e) {
      error = e.message ?? 'Authentication failed';
    } catch (e) {
      error = e.toString();
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
