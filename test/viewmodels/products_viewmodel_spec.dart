import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:flutcom/models/product.dart';
import 'package:flutcom/services/api_service.dart';
import 'package:flutcom/viewmodels/products_viewmodel.dart';

class MockApiService extends Mock implements ApiService {}
void main() {
  group('ProductsViewModel with MockApiService', () {
    late ProductsViewModel viewModel;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      // Par défaut, éviter l'appel réseau déclenché par le constructeur
      when(mockApiService.fetchProducts()).thenAnswer((_) async => []);
      viewModel = ProductsViewModel(apiService: mockApiService);
    });

    test('should load products from ApiService', () async {
      // Arrange
      final fakeProducts = [
        Product(
            id: 1,
            title: 'Test Product 1',
            price: 9.99,
            description: 'desc',
            category: 'cat',
            image: 'url',
            rating: Rating(rate: 4.5, count: 10)),
        Product(
            id: 2,
            title: 'Test Product 2',
            price: 19.99,
            description: 'desc',
            category: 'cat',
            image: 'url',
            rating: Rating(rate: 4.0, count: 5)),
      ];
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => fakeProducts);

      // Act
      await viewModel.loadProducts();

      // Assert
      expect(viewModel.products.length, equals(2));
      expect(viewModel.products.first.title, equals('Test Product 1'));
      verify(mockApiService.fetchProducts()).called(greaterThanOrEqualTo(1));
    });

    test('should handle empty list of products', () async {
      when(mockApiService.fetchProducts()).thenAnswer((_) async => []);

      await viewModel.loadProducts();

      expect(viewModel.products, isEmpty);
    });

    test('should set isLoading correctly', () async {
      when(mockApiService.fetchProducts()).thenAnswer((_) async => []);

      // Avant le chargement
      expect(viewModel.isLoading, isFalse);

      final future = viewModel.loadProducts();
      // Pendant le chargement
      expect(viewModel.isLoading, isTrue);

      await future;
      // Après le chargement
      expect(viewModel.isLoading, isFalse);
    });

    test('should set an error message on API failure', () async {
      when(mockApiService.fetchProducts())
          .thenThrow(Exception('Failed to load'));

      await viewModel.loadProducts();

      expect(viewModel.hasError, isTrue);
      expect(
          viewModel.errorMessage, equals('Impossible de charger les produits'));
      expect(viewModel.products, isEmpty);
    });
  });
}
