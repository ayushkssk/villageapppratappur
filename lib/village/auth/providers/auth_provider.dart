import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  // Initialize the provider
  void init() {
    _authService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email!,
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
          phoneNumber: firebaseUser.phoneNumber,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  // Sign Up with Email
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      await _authService.signUpWithEmail(email, password);
    } finally {
      _setLoading(false);
    }
  }

  // Sign In with Email
  Future<void> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      await _authService.signInWithEmail(email, password);
    } finally {
      _setLoading(false);
    }
  }

  // Sign In with Google
  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      await _authService.signInWithGoogle();
    } finally {
      _setLoading(false);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
    } finally {
      _setLoading(false);
    }
  }

  // Reset Password
  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _authService.resetPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
