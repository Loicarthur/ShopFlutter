import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutcom/services/auth_service.dart';

// Génération automatique des mocks
@GenerateMocks([FirebaseAuth, User, UserCredential])
import 'auth_service_test.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late AuthService authService;
    late MockFirebaseAuth mockFirebaseAuth;
    late MockUser mockUser;
    late MockUserCredential mockUserCredential;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockUser = MockUser();
      mockUserCredential = MockUserCredential();

      // Obtenir l'instance singleton
      authService = AuthService.instance;
    });

    test('AuthService should be singleton', () {
      final instance1 = AuthService.instance;
      final instance2 = AuthService.instance;

      expect(identical(instance1, instance2), isTrue);
    });

    test('currentUser should return current user from FirebaseAuth', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);

      // Act
      final currentUser = authService.currentUser;

      // Assert
      expect(currentUser, equals(mockUser));
    });

    test('currentUser should return null when no user signed in', () {
      // Arrange
      when(mockFirebaseAuth.currentUser).thenReturn(null);

      // Act
      final currentUser = authService.currentUser;

      // Assert
      expect(currentUser, isNull);
    });

    test('authStateChanges should return stream from FirebaseAuth', () {
      // Arrange
      final userStream = Stream<User?>.fromIterable([mockUser, null]);
      when(mockFirebaseAuth.authStateChanges()).thenAnswer((_) => userStream);

      // Act
      final stream = authService.authStateChanges;

      // Assert
      expect(stream, isA<Stream<User?>>());
    });

    group('registerWithEmailAndPassword', () {
      test('should return user on successful registration', () async {
        // Arrange
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final user = await authService.registerWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(user, equals(mockUser));
        verify(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should throw formatted error on FirebaseAuthException', () async {
        // Arrange
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'weak',
        )).thenThrow(FirebaseAuthException(
          code: 'weak-password',
          message: 'The password is too weak',
        ));

        // Act & Assert
        expect(
          () => authService.registerWithEmailAndPassword(
            email: 'test@example.com',
            password: 'weak',
          ),
          throwsA(equals('Mot de passe trop faible.')),
        );
      });

      test('should handle email-already-in-use error', () async {
        // Arrange
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'existing@example.com',
          password: 'password123',
        )).thenThrow(FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email already in use',
        ));

        // Act & Assert
        expect(
          () => authService.registerWithEmailAndPassword(
            email: 'existing@example.com',
            password: 'password123',
          ),
          throwsA(equals('Cette adresse email est déjà utilisée.')),
        );
      });
    });

    group('signInWithEmailAndPassword', () {
      test('should return user on successful sign in', () async {
        // Arrange
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenAnswer((_) async => mockUserCredential);

        // Act
        final user = await authService.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        );

        // Assert
        expect(user, equals(mockUser));
        verify(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).called(1);
      });

      test('should throw formatted error on user-not-found', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'nonexistent@example.com',
          password: 'password123',
        )).thenThrow(FirebaseAuthException(
          code: 'user-not-found',
          message: 'User not found',
        ));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'nonexistent@example.com',
            password: 'password123',
          ),
          throwsA(equals('Utilisateur non trouvé.')),
        );
      });

      test('should throw formatted error on wrong-password', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        )).thenThrow(FirebaseAuthException(
          code: 'wrong-password',
          message: 'Wrong password',
        ));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'wrongpassword',
          ),
          throwsA(equals('Mot de passe incorrect.')),
        );
      });

      test('should handle invalid-email error', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'invalid-email',
          password: 'password123',
        )).thenThrow(FirebaseAuthException(
          code: 'invalid-email',
          message: 'Invalid email',
        ));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'invalid-email',
            password: 'password123',
          ),
          throwsA(equals('Adresse email invalide.')),
        );
      });
    });

    test('signOut should call FirebaseAuth signOut', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      await authService.signOut();

      // Assert
      verify(mockFirebaseAuth.signOut()).called(1);
    });

    group('Error handling', () {
      test('should handle user-disabled error', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'disabled@example.com',
          password: 'password123',
        )).thenThrow(FirebaseAuthException(
          code: 'user-disabled',
          message: 'User disabled',
        ));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'disabled@example.com',
            password: 'password123',
          ),
          throwsA(equals('Utilisateur désactivé.')),
        );
      });

      test('should handle operation-not-allowed error', () async {
        // Arrange
        when(mockFirebaseAuth.createUserWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenThrow(FirebaseAuthException(
          code: 'operation-not-allowed',
          message: 'Operation not allowed',
        ));

        // Act & Assert
        expect(
          () => authService.registerWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(equals('Connexion par email/mot de passe désactivée.')),
        );
      });

      test('should handle unknown error codes', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenThrow(FirebaseAuthException(
          code: 'unknown-error',
          message: 'Some unknown error occurred',
        ));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(equals('Erreur inconnue : Some unknown error occurred')),
        );
      });

      test('should handle FirebaseAuthException without message', () async {
        // Arrange
        when(mockFirebaseAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        )).thenThrow(FirebaseAuthException(
          code: 'unknown-error',
        ));

        // Act & Assert
        expect(
          () => authService.signInWithEmailAndPassword(
            email: 'test@example.com',
            password: 'password123',
          ),
          throwsA(contains('Erreur inconnue')),
        );
      });
    });
  });
}
