import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service_test.mocks.dart';
import 'package:flutcom/services/auth_service.dart';

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late AuthService authService;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    authService = AuthService(firebaseAuth: mockFirebaseAuth);
  });

  group('AuthService Tests', () {
    test(
        'loginWithEmail devrait appeler FirebaseAuth.signInWithEmailAndPassword',
        () async {
      // Arrange
      when(mockFirebaseAuth.signInWithEmailAndPassword(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => mockUserCredential);

      // Act
      final result =
          await authService.loginWithEmail('test@test.com', '123456');

      // Assert
      expect(result, isA<UserCredential>());
      verify(mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@test.com',
        password: '123456',
      )).called(1);
    });

    test('logout devrait appeler FirebaseAuth.signOut', () async {
      // Arrange
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});

      // Act
      await authService.logout();

      // Assert
      verify(mockFirebaseAuth.signOut()).called(1);
    });
  });
}
