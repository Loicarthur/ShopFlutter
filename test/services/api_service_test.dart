import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:http/http.dart' as http;
import 'package:flutcom/services/api_service.dart';
import 'package:flutcom/models/product.dart';
import 'dart:convert';

// Génération automatique des mocks
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      apiService = ApiService();
      mockClient = MockClient();
    });

    final sampleProductsJson = [
      {
        'id': 1,
        'title': 'Test Product 1',
        'price': 29.99,
        'description': 'Test description 1',
        'category': 'electronics',
        'image': 'https://example.com/image1.jpg',
        'rating': {'rate': 4.5, 'count': 120}
      },
      {
        'id': 2,
        'title': 'Test Product 2',
        'price': 19.99,
        'description': 'Test description 2',
        'category': 'clothing',
        'image': 'https://example.com/image2.jpg',
        'rating': {'rate': 3.8, 'count': 85}
      }
    ];

    test('fetchProducts should return list of products on successful response',
        () async {
      // Arrange
      final responseBody = json.encode(sampleProductsJson);
      when(mockClient.get(
        Uri.parse('${ApiService.baseUrl}/products'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final products = await apiService.fetchProducts();

      // Assert
      expect(products.length, equals(2));
      expect(products[0].id, equals(1));
      expect(products[0].title, equals('Test Product 1'));
      expect(products[0].price, equals(29.99));
      expect(products[1].id, equals(2));
      expect(products[1].title, equals('Test Product 2'));
      expect(products[1].price, equals(19.99));
    });

    test('fetchProducts should throw exception on HTTP error status', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('${ApiService.baseUrl}/products'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response('Not Found', 404));

      // Act & Assert
      expect(
        () => apiService.fetchProducts(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Erreur serveur : 404'),
        )),
      );
    });

    test('fetchProducts should handle network timeout', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('${ApiService.baseUrl}/products'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async {
        await Future.delayed(
            const Duration(seconds: 15)); // Plus que le timeout
        return http.Response('', 200);
      });

      // Act & Assert
      // Note: Le service a un fallback local, donc il ne devrait pas throw
      // mais retourner les données locales
      final products = await apiService.fetchProducts();
      expect(products, isA<List<Product>>());
    });

    test('fetchProducts should handle invalid JSON response', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('${ApiService.baseUrl}/products'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response('Invalid JSON', 200));

      // Act & Assert
      // Le service devrait fallback vers les données locales
      final products = await apiService.fetchProducts();
      expect(products, isA<List<Product>>());
    });

    test('fetchProducts should handle empty response', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('${ApiService.baseUrl}/products'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response('[]', 200));

      // Act
      final products = await apiService.fetchProducts();

      // Assert
      expect(products, isEmpty);
    });

    test('fetchProducts should use correct URL and headers', () async {
      // Arrange
      when(mockClient.get(
        Uri.parse('${ApiService.baseUrl}/products'),
        headers: {'Content-Type': 'application/json'},
      )).thenAnswer((_) async => http.Response('[]', 200));

      // Act
      await apiService.fetchProducts();

      // Assert
      verify(mockClient.get(
        Uri.parse('https://fakestoreapi.com/products'),
        headers: {'Content-Type': 'application/json'},
      )).called(1);
    });

    test('fetchProducts should parse products correctly from complex JSON',
        () async {
      // Arrange
      final complexProductJson = [
        {
          'id': 3,
          'title': 'Complex Product',
          'price': 99.99,
          'description':
              'A very detailed description with special characters: éàù',
          'category': 'jewelery',
          'image': 'https://example.com/complex-image.jpg',
          'rating': {'rate': 4.9, 'count': 500}
        }
      ];

      final responseBody = json.encode(complexProductJson);
      when(mockClient.get(any, headers: anyNamed('headers')))
          .thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final products = await apiService.fetchProducts();

      // Assert
      expect(products.length, equals(1));
      final product = products.first;
      expect(product.id, equals(3));
      expect(product.title, equals('Complex Product'));
      expect(product.price, equals(99.99));
      expect(product.description, contains('éàù'));
      expect(product.category, equals('jewelery'));
      expect(product.rating.rate, equals(4.9));
      expect(product.rating.count, equals(500));
    });

    test('baseUrl should be correct', () {
      expect(ApiService.baseUrl, equals('https://fakestoreapi.com'));
    });

    test('fetchProducts should handle server error codes', () async {
      final errorCodes = [400, 401, 403, 500, 502, 503];

      for (final code in errorCodes) {
        // Arrange
        when(mockClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('Error', code));

        // Act & Assert
        expect(
          () => apiService.fetchProducts(),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Erreur serveur : $code'),
          )),
        );
      }
    });
  });
}
