import 'package:flutter/foundation.dart';

class AppUser {
  final String name;
  final String email;

  const AppUser({required this.name, required this.email});

  String get initial =>
      name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();
}

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final ValueNotifier<AppUser?> currentUser = ValueNotifier<AppUser?>(null);

  bool get isLoggedIn => currentUser.value != null;

  Future<void> login({required String email, String? displayName}) async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    final name = (displayName == null || displayName.trim().isEmpty)
        ? email.split('@').first
        : displayName.trim();
    currentUser.value = AppUser(name: name, email: email);
  }

  void logout() {
    currentUser.value = null;
  }
}
