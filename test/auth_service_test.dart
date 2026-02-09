import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bp_monitor/core/errors.dart';
import 'package:bp_monitor/infra/auth_service.dart';

void main() {
  group('AuthService', () {
    late MockFirebaseAuth mockAuth;
    late AuthService authService;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      authService = AuthService(firebaseAuth: mockAuth);
    });

    test('signUp returns Success with user', () async {
      final result = await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<dynamic>>());
      final user = (result as Success).value;
      expect(user.email, 'test@example.com');
    });

    test('login returns Success with user', () async {
      // First sign up so the mock user exists.
      await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      final result = await authService.login(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(result, isA<Success<dynamic>>());
    });

    test('logout returns Success', () async {
      // Sign up first so there is a user to log out.
      await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      final result = await authService.logout();

      expect(result, isA<Success<dynamic>>());
      expect(authService.currentUser, isNull);
    });

    test('resetPassword returns Success', () async {
      final result = await authService.resetPassword(
        email: 'test@example.com',
      );

      expect(result, isA<Success<dynamic>>());
    });

    test('currentUser is set after sign-up', () async {
      expect(authService.currentUser, isNull);

      await authService.signUp(
        email: 'test@example.com',
        password: 'password123',
      );

      expect(authService.currentUser, isNotNull);
      expect(authService.currentUser?.email, 'test@example.com');
    });
  });
}
