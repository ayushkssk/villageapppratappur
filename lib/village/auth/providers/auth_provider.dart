import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class VillageAuthProvider with ChangeNotifier {
  final AuthService _authService;
  UserModel? _user;
  bool _isLoading = false;
  bool _isOfflineMode = false;
  bool _isDemoMode = false;
  String? _offlineUserName;

  VillageAuthProvider(this._authService) {
    init();
  }

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isOfflineMode => _isOfflineMode;
  bool get isDemoMode => _isDemoMode;
  String? get offlineUserName => _offlineUserName;
  bool get isAuthenticated => _user != null || _isOfflineMode || _isDemoMode;
  Stream<User?> get authStateStream => _authService.authStateChanges;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void init() {
    _authService.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _user = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName,
          photoURL: firebaseUser.photoURL,
          phoneNumber: firebaseUser.phoneNumber,
          lastUpdated: DateTime.now(),
        );
      } else {
        _user = null;
      }
      notifyListeners();
    });
  }

  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      final userCredential = await _authService.signUpWithEmail(email, password);
      if (userCredential.user != null) {
        _user = UserModel.fromFirebaseUser(
          userCredential.user!.uid,
          userCredential.user!.email ?? '',
        );
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    try {
      _setLoading(true);
      final userCredential = await _authService.signInWithEmail(email, password);
      if (userCredential.user != null) {
        _user = UserModel.fromFirebaseUser(
          userCredential.user!.uid,
          userCredential.user!.email ?? '',
        );
        notifyListeners();
      }
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      final userCredential = await _authService.signInWithGoogle();
      if (userCredential.user != null) {
        _user = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
          phoneNumber: userCredential.user!.phoneNumber,
          lastUpdated: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error in signInWithGoogle: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithDemo() async {
    try {
      _setLoading(true);
      _isDemoMode = true;
      _isOfflineMode = false;
      _user = UserModel(
        uid: 'guest_user',
        email: 'guest@local',
        name: 'Guest',
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      await _authService.signOut();
      _user = null;
      _isOfflineMode = false; // Make sure to clear offline mode too
      _isDemoMode = false;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setLoading(true);
      await _authService.resetPassword(email);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUserProfile(String displayName) async {
    try {
      _setLoading(true);
      await _authService.updateUserProfile(displayName);
      
      if (_user != null) {
        _user = _user!.copyWith(
          displayName: displayName,
          lastUpdated: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      print('Error in VillageAuthProvider.updateUserProfile: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> enterOfflineMode({String? userName}) async {
    _isOfflineMode = true;
    _isDemoMode = false;
    _offlineUserName = userName;
    _user = UserModel(
      uid: 'offline_user',
      email: 'offline@local',
      name: userName ?? 'Offline User',
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
  }

  Future<void> exitOfflineMode() async {
    _isOfflineMode = false;
    _isDemoMode = false;
    _offlineUserName = null;
    _user = null;
    notifyListeners();
  }

  Future<void> updateOfflineUserName(String name) async {
    if (_isOfflineMode && _user != null) {
      _offlineUserName = name;
      _user = _user!.copyWith(name: name);
      notifyListeners();
    }
  }
}
