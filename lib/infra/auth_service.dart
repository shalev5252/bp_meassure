import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/core/logger.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Wrapper around [FirebaseAuth] providing a clean API
/// for sign-up, login, password reset, and logout.
class AuthService {
  AuthService({FirebaseAuth? firebaseAuth})
      : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  /// Current Firebase user, or null if signed out.
  User? get currentUser => _auth.currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign up with email and password.
  Future<Result<User>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Err(AuthFailure('Sign-up succeeded but user is null'));
      }
      AppLogger.info('User signed up: ${user.uid}', tag: 'AUTH');
      return Success(user);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Sign-up failed: ${e.code}', tag: 'AUTH', error: e);
      return Err(AuthFailure(_mapFirebaseCode(e.code)));
    }
  }

  /// Login with email and password.
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        return const Err(AuthFailure('Login succeeded but user is null'));
      }
      AppLogger.info('User logged in: ${user.uid}', tag: 'AUTH');
      return Success(user);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Login failed: ${e.code}', tag: 'AUTH', error: e);
      return Err(AuthFailure(_mapFirebaseCode(e.code)));
    }
  }

  /// Send password reset email.
  Future<Result<void>> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      AppLogger.info('Password reset email sent', tag: 'AUTH');
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error(
        'Password reset failed: ${e.code}',
        tag: 'AUTH',
        error: e,
      );
      return Err(AuthFailure(_mapFirebaseCode(e.code)));
    }
  }

  /// Sign out.
  Future<Result<void>> logout() async {
    try {
      await _auth.signOut();
      AppLogger.info('User logged out', tag: 'AUTH');
      return const Success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.error('Logout failed: ${e.code}', tag: 'AUTH', error: e);
      return Err(AuthFailure(_mapFirebaseCode(e.code)));
    }
  }

  /// Map Firebase error codes to user-friendly messages.
  String _mapFirebaseCode(String code) {
    return switch (code) {
      'email-already-in-use' => 'An account with this email already exists.',
      'invalid-email' => 'The email address is not valid.',
      'weak-password' => 'The password is too weak.',
      'user-not-found' => 'No account found for this email.',
      'wrong-password' => 'Incorrect password.',
      'user-disabled' => 'This account has been disabled.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'invalid-credential' => 'Invalid email or password.',
      _ => 'Authentication error ($code).',
    };
  }
}
