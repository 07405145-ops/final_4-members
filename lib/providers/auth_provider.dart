import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

enum AuthStatus { loading, signedOut, student, staff }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _listen();
  }

  final AuthService _service;
  late StreamSubscription<User?> _sub;
  int _authGeneration = 0;

  AuthStatus status = AuthStatus.loading;
  User? user;
  bool busy = false;
  String? error;

  void _listen() {
    final generation = ++_authGeneration;
    _sub = _service.authChanges.listen(
      (user) => _onAuthChanged(user, generation),
    );
  }

  Future<void> _onAuthChanged(User? u, int generation) async {
    if (generation != _authGeneration) return;
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
      role = 'student';
    }
    if (user?.uid != u.uid || generation != _authGeneration) return;
    status = role == 'staff' ? AuthStatus.staff : AuthStatus.student;
    notifyListeners();
  }

  void refresh() {
    status = AuthStatus.loading;
    notifyListeners();
    _sub.cancel();
    _listen();
  }

  Future<Map<String, String>?> login(String email, String password) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final result = await _service.login(email, password);
      return result;
    } on FirebaseAuthException catch (e) {
      error = e.message ?? 'Authentication failed';
      return null;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
      return null;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password) =>
      _run(() => _service.register(name, email, password));

  Future<void> logout() => _run(() => _service.logout());

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
      error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _authGeneration++;
    _sub.cancel();
    super.dispose();
  }
}
