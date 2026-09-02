import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Stream to track real-time user auth status cross the app UI
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Retrieve current active user profile
  User? get currentUser => _firebaseAuth.currentUser;

  // Standard Email & Password Sign In
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Natively fetches the JWT ID token.
  // Set forceRefresh to true only if custom claims were altered recently.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // Automatically fetches a fresh token if the old one expired
        return await user.getIdToken(forceRefresh);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign Out User (Logs out of Firebase)
  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
