import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:vraiauth/models/product.dart';
import 'package:vraiauth/viewmodels/products_viewmodel.dart';
import 'package:vraiauth/services/api_service.dart'; // Importez l'ApiService pour le mocking

// Utilisez une annotation pour générer le mock.
// Assurez-vous d'avoir build_runner et mockito dans vos dev_dependencies.
@GenerateMocks([ApiService])
import 'products_viewmodel_test.mocks.dart';

void main() {
  group('ProductsViewModel with MockApiService', () {
    late ProductsViewModel viewModel;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      // L'injection de dépendance fonctionne maintenant !
      viewModel = ProductsViewModel(apiService: mockApiService);
    });

    test('should load products from ApiService', () async {
      // Arrange : on configure le mock pour retourner une liste de produits
      final fakeProducts = [
        Product(id: 1, title: 'Test Product 1', price: 9.99, description: 'desc', category: 'cat', image: 'url', rating: Rating(rate: 4.5, count: 100)),
        Product(id: 2, title: 'Test Product 2', price: 19.99, description: 'desc', category: 'cat', image: 'url', rating: Rating(rate: 4.0, count: 200)),
      ];

      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => fakeProducts);

      // Act
      await viewModel.loadProducts();

      // Assert
      expect(viewModel.products.length, equals(2));
      expect(viewModel.products.first.title, equals('Test Product 1'));
      verify(mockApiService.fetchProducts()).called(1);
    });

    test('should handle empty list of products', () async {
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => []);

      await viewModel.loadProducts();

      expect(viewModel.products, isEmpty);
    });

    test('should set isLoading correctly during product loading', () async {
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => []);

      // L'état initial est déjà en chargement à cause du constructeur
      // On attend la fin du premier chargement pour pouvoir tester proprement.
      await viewModel.loadProducts();
      
      expect(viewModel.isLoading, isFalse);

      final future = viewModel.loadProducts();
      // Juste après l'appel, isLoading doit être true
      expect(viewModel.isLoading, isTrue);

      await future;
      // Une fois le futur complété, isLoading doit revenir à false
      expect(viewModel.isLoading, isFalse);
    });

    test('should set an error message on API failure', () async {
      // Arrange
      when(mockApiService.fetchProducts())
          .thenThrow(Exception('Failed to load'));

      // Act
      await viewModel.loadProducts();

      // Assert
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, equals('Impossible de charger les produits'));
      expect(viewModel.products, isEmpty);
    });
  });
}
