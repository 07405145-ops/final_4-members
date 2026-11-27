import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'prefs_service.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Stream<User?> get authChanges => _auth.authStateChanges();

  Future<void> register(
    String name,
    String email,
    String password,
    String role,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    try {
      await _db.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': user.email ?? email.trim(),
        'role': role,
        'phone': '',
        'address': '',
        'photoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException {
      try {
        await user.delete();
      } on FirebaseAuthException catch (error) {
        throw StateError(
          'The account was created, but its profile could not be saved and the account could not be removed (${error.code}). Contact support before trying again.',
        );
      }
      rethrow;
    }
    await _auth.signOut();
  }

  Future<Map<String, String>> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    try {
      final profile = await _db.collection('users').doc(user.uid).get();
      final data = profile.data();
      if (data == null) {
        await _auth.signOut();
        throw StateError('Account profile not found. Please register again.');
      }
      return {
        'email': user.email ?? email.trim(),
        'name': (data['name'] as String?) ?? user.displayName ?? email.trim(),
        'uid': user.uid,
      };
    } on FirebaseException {
      await _auth.signOut();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await PrefsService.clearLogin();
  }

  Future<String> getRole(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return (doc.data()?['role'] as String?) ?? 'student';
  }
}
