import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  FirebaseAuth? _auth;

  AuthRepository({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth;

  FirebaseAuth get _firebaseAuth {
    return _auth ??= FirebaseAuth.instance;
  }

  // Stream to track real-time user auth status across the app UI
  Stream<User?> get authStateChanges {
    try {
      return _firebaseAuth.authStateChanges();
    } catch (_) {
      return const Stream.empty();
    }
  }

  // Retrieve current active user profile
  User? get currentUser {
    try {
      return _firebaseAuth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get isAuthenticated => currentUser != null;

  // Standard Email & Password Sign In
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Standard Email & Password Sign Up / Registration
  Future<UserCredential> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  // Password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  // Natively fetches the JWT ID token.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    try {
      final user = currentUser;
      if (user != null) {
        return await user.getIdToken(forceRefresh);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Sign Out User (Logs out of Firebase)
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (_) {}
  }
}
