import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) =>
      _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

  Future<UserModel> login({
    required String email,
    required String password,
  }) =>
      _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

  Future<void> logout() => _authService.signOut();
}
