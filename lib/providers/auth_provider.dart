import 'package:flutter/foundation.dart';
import 'package:prime_access/models/user.dart';
import 'package:prime_access/services/api_service.dart';
import 'package:prime_access/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService;
  final AuthService _authService;

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider({
    required ApiService apiService,
    required AuthService authService,
  })  : _apiService = apiService,
        _authService = authService;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  Future<void> tryAutoLogin() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final savedUser = await _authService.getSavedUser();
    if (savedUser != null) {
      _user = savedUser;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _apiService.login(email, password);
      if (user != null) {
        _user = user;
        await _authService.saveSession(user);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Email ou code incorrect';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur de connexion au serveur';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String login,
    required String password,
    required String firstName,
    required String lastName,
    required String email,
    String? phone,
    String? role,
    String? contractor,
    String? imageBase64,
    String? imageExtension,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _apiService.register(
        login: login,
        password: password,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        fonction: role,
        contractor: contractor,
        imageBase64: imageBase64,
        imageExtension: imageExtension,
      );
      if (user != null) {
        _user = user;
        await _authService.saveSession(user);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Erreur lors de l\'inscription';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Erreur de connexion au serveur';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.clearSession();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void updateUser(User updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
