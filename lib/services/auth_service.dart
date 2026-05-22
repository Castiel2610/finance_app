import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'database_service.dart';

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final DatabaseService _db;

  AuthService({
    FirebaseAuth? firebaseAuth,
    DatabaseService? db,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _db = db ?? DatabaseService.instance;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    // Check if email already exists locally
    if (await _db.emailExists(email)) {
      throw const AuthException('E-mail já cadastrado.');
    }

    UserCredential? credential;
    String userId;

    try {
      credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      userId = credential.user!.uid;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw const AuthException('E-mail já cadastrado no Firebase.');
        case 'weak-password':
          throw const AuthException('Senha muito fraca. Use ao menos 6 caracteres.');
        default:
          // Firebase unavailable - generate local ID
          userId = DateTime.now().millisecondsSinceEpoch.toString();
      }
    } catch (_) {
      userId = DateTime.now().millisecondsSinceEpoch.toString();
    }

    final user = UserModel(
      id: userId,
      name: name,
      email: email,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    await _db.insertUser(user);
    return user;
  }

  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;

      var localUser = await _db.getUserById(uid);
      if (localUser == null) {
        localUser = UserModel(
          id: uid,
          name: credential.user?.displayName ?? email.split('@').first,
          email: email,
          passwordHash: _hashPassword(password),
          createdAt: DateTime.now(),
        );
        await _db.insertUser(localUser);
      }
      return localUser;
    } on FirebaseAuthException catch (e) {
      // Try local auth as fallback
      return _signInLocally(email: email, password: password, firebaseError: e);
    } catch (_) {
      return _signInLocally(email: email, password: password);
    }
  }

  Future<UserModel> _signInLocally({
    required String email,
    required String password,
    FirebaseAuthException? firebaseError,
  }) async {
    final user = await _db.getUserByEmail(email);
    if (user == null) {
      throw const AuthException('Usuário não encontrado.');
    }
    if (user.passwordHash != _hashPassword(password)) {
      throw const AuthException('Senha incorreta.');
    }
    return user;
  }

  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
