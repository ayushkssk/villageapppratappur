import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );
  final SharedPreferences _prefs;
  static const String _userCacheKey = 'cached_user_data';
  static const Duration _cacheExpiry = Duration(hours: 24);

  AuthService(this._prefs);

  static Future<AuthService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthService(prefs);
  }

  // Cache management
  final Map<String, UserModel> _userCache = {};

  void _initializeCache() {
    final cachedData = _prefs.getString(_userCacheKey);
    if (cachedData != null) {
      try {
        final userData = UserModel.fromJson(json.decode(cachedData));
        final cacheTime = _prefs.getInt('${_userCacheKey}_time') ?? 0;
        if (DateTime.now().millisecondsSinceEpoch - cacheTime < _cacheExpiry.inMilliseconds) {
          _userCache[userData.uid] = userData;
        }
      } catch (e) {
        print('Error loading cached user data: $e');
      }
    }
  }

  Future<void> _cacheUserData(UserModel user) async {
    _userCache[user.uid] = user;
    await _prefs.setString(_userCacheKey, json.encode(user.toJson()));
    await _prefs.setInt('${_userCacheKey}_time', DateTime.now().millisecondsSinceEpoch);
  }

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final userData = {
          'uid': userCredential.user!.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(userCredential.user!.uid).set(userData);
        
        final userModel = UserModel.fromFirebaseUser(
          userCredential.user!.uid,
          email,
        );
        await _cacheUserData(userModel);
      }

      return userCredential;
    } catch (e) {
      print('Error in signUpWithEmail: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Try to get user from cache first
        final cachedUser = _userCache[userCredential.user!.uid];
        if (cachedUser != null) {
          return userCredential;
        }
        
        // If not in cache, fetch from Firestore
        final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
        if (userDoc.exists) {
          final userModel = UserModel.fromFirebaseUser(
            userCredential.user!.uid,
            email,
          );
          await _cacheUserData(userModel);
        }
      }
      
      return userCredential;
    } catch (e) {
      print('Error in signInWithEmail: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Clear any existing sessions
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google Sign In was cancelled');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final userData = {
          'uid': userCredential.user!.uid,
          'email': userCredential.user!.email,
          'displayName': userCredential.user!.displayName,
          'photoURL': userCredential.user!.photoURL,
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        await _firestore.collection('users').doc(userCredential.user!.uid).set(
          userData,
          SetOptions(merge: true),
        );
        
        final userModel = UserModel.fromFirebaseUser(
          userCredential.user!.uid,
          userCredential.user!.email ?? '',
        );
        await _cacheUserData(userModel);
      }

      return userCredential;
    } catch (e) {
      print('Error in signInWithGoogle: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid != null) {
        _userCache.remove(uid);
        await _prefs.remove(_userCacheKey);
        await _prefs.remove('${_userCacheKey}_time');
      }
      
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Error in signOut: $e');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error in resetPassword: $e');
      rethrow;
    }
  }

  Future<void> updateUserProfile(String displayName) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': displayName,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        
        if (_userCache.containsKey(user.uid)) {
          final updatedUser = _userCache[user.uid]!.copyWith(displayName: displayName);
          await _cacheUserData(updatedUser);
        }
      }
    } catch (e) {
      print('Error in updateUserProfile: $e');
      rethrow;
    }
  }
}
