import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
    hostedDomain: '',  // Allow any domain
    clientId: '', // Optional: Add your client ID here if needed
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUpWithEmail(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'uid': userCredential.user!.uid,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      return userCredential;
    } catch (e) {
      print('Error in signUpWithEmail: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error in signInWithEmail: $e');
      rethrow;
    }
  }

  Future<UserCredential> signInWithGoogle() async {
    try {
      // Sign out first to force account selection
      await _googleSignIn.signOut();
      await _auth.signOut();

      // Show account picker
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Sign in cancelled by user');
      }

      try {
        // Get auth details
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create Firebase credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in with Firebase
        final userCredential = await _auth.signInWithCredential(credential);

        // Update Firestore data
        if (userCredential.user != null) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'uid': userCredential.user!.uid,
            'email': userCredential.user!.email,
            'displayName': userCredential.user!.displayName,
            'photoURL': userCredential.user!.photoURL,
            'lastSignInTime': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
        }

        return userCredential;
      } catch (e) {
        print('Firebase Auth Error: $e');
        throw Exception('Failed to sign in with Google');
      }
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
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
        // First update Firebase Auth
        await user.updateDisplayName(displayName);

        // Get current user data
        final userRef = _firestore.collection('users').doc(user.uid);
        final userDoc = await userRef.get();
        
        // Get old name for history
        String oldName = 'Not Set';
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['displayName'] != null) {
            oldName = data['displayName'].toString();
          }
        }

        // Update Firestore user profile
        await userRef.set({
          'displayName': displayName,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // Add update to history
        await _firestore.collection('profile_updates').add({
          'userId': user.uid,
          'oldName': oldName,
          'newName': displayName,
          'timestamp': FieldValue.serverTimestamp(),
        });

        // Refresh the user
        await user.reload();
      } else {
        throw Exception('No user is currently logged in');
      }
    } catch (e) {
      print('Error in updateUserProfile: $e');
      throw Exception('Failed to update profile: $e');
    }
  }
}
