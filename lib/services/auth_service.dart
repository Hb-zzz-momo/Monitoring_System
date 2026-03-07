import 'api_service.dart' as api;

class AuthService {
  Future<Map<String, dynamic>> login(String username, String password) {
    return api.login(username, password);
  }

  Future<Map<String, dynamic>> register(
    String username,
    String password, {
    String? displayName,
    String? email,
    String? phone,
  }) {
    return api.register(
      username,
      password,
      displayName: displayName,
      email: email,
      phone: phone,
    );
  }

  Future<void> logout() {
    return api.logout();
  }

  Future<void> restoreSession() {
    return api.restoreAuthSession();
  }

  bool get isLoggedIn => api.isLoggedIn;

  Map<String, dynamic>? get currentUser => api.currentUser;
}

final AuthService authService = AuthService();
