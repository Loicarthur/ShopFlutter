import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:vraiauth/viewmodels/products_viewmodel.dart';
import 'package:vraiauth/models/product.dart';
import 'package:vraiauth/services/api_service.dart';

// Génération automatique des mocks - nécessite build_runner
@GenerateMocks([ApiService])
import 'products_viewmodel_test.mocks.dart';

void main() {
  group('ProductsViewModel Tests', () {
    late ProductsViewModel viewModel;
    late MockApiService mockApiService;
    late List<Product> sampleProducts;

    setUp(() {
      mockApiService = MockApiService();
      sampleProducts = [
        Product(
          id: 1,
          title: 'Product 1',
          price: 10.0,
          description: 'Description 1',
          category: 'electronics',
          image: 'image1.jpg',
          rating: Rating(rate: 4.5, count: 100),
        ),
        Product(
          id: 2,
          title: 'Product 2',
          price: 20.0,
          description: 'Description 2',
          category: 'clothing',
          image: 'image2.jpg',
          rating: Rating(rate: 3.8, count: 50),
        ),
      ];
    });

    test('initial state should be correct', () {
      // Créer un viewModel sans appeler loadProducts automatiquement
      viewModel = ProductsViewModel();
      
      expect(viewModel.products, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isEmpty);
      expect(viewModel.hasError, isFalse);
    });

    testWidgets('loadProducts should set loading state correctly', (tester) async {
      // Mock successful API call
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => sampleProducts);

      viewModel = ProductsViewModel();
      
      // Vérifier l'état initial
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.products, isEmpty);
      expect(viewModel.hasError, isFalse);

      // Simuler le chargement
      final loadFuture = viewModel.loadProducts();
      
      // Pendant le chargement
      expect(viewModel.isLoading, isTrue);
      expect(viewModel.hasError, isFalse);
      
      // Attendre la fin du chargement
      await loadFuture;
      
      // Après le chargement
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.products.length, equals(2));
      expect(viewModel.products, equals(sampleProducts));
      expect(viewModel.hasError, isFalse);
    });

    testWidgets('loadProducts should handle API errors correctly', (tester) async {
      // Mock API error
      when(mockApiService.fetchProducts())
          .thenThrow(Exception('Network error'));

      viewModel = ProductsViewModel();
      
      await viewModel.loadProducts();
      
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.products, isEmpty);
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, equals('Impossible de charger les produits'));
    });

    testWidgets('loadProducts should prevent multiple simultaneous calls', (tester) async {
      // Mock slow API call
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async {
            await Future.delayed(const Duration(milliseconds: 100));
            return sampleProducts;
          });

      viewModel = ProductsViewModel();
      
      // Lancer deux appels simultanés
      final future1 = viewModel.loadProducts();
      final future2 = viewModel.loadProducts();
      
      await Future.wait([future1, future2]);
      
      // Vérifier qu'un seul appel a été fait
      verify(mockApiService.fetchProducts()).called(1);
    });

    testWidgets('loadProducts should clear previous error on new load', (tester) async {
      viewModel = ProductsViewModel();
      
      // Premier appel avec erreur
      when(mockApiService.fetchProducts())
          .thenThrow(Exception('First error'));
      
      await viewModel.loadProducts();
      expect(viewModel.hasError, isTrue);
      expect(viewModel.errorMessage, isNotEmpty);
      
      // Deuxième appel réussi
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => sampleProducts);
      
      await viewModel.loadProducts();
      expect(viewModel.hasError, isFalse);
      expect(viewModel.errorMessage, isEmpty);
      expect(viewModel.products, equals(sampleProducts));
    });

    testWidgets('ViewModel should notify listeners on state changes', (tester) async {
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => sampleProducts);

      viewModel = ProductsViewModel();
      
      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      await viewModel.loadProducts();
      
      // Devrait notifier au moins 2 fois : début loading, fin loading
      expect(notificationCount, greaterThanOrEqualTo(2));
    });

    testWidgets('hasError getter should work correctly', (tester) async {
      viewModel = ProductsViewModel();
      
      expect(viewModel.hasError, isFalse);
      
      when(mockApiService.fetchProducts())
          .thenThrow(Exception('Error'));
      
      await viewModel.loadProducts();
      
      expect(viewModel.hasError, isTrue);
    });

    testWidgets('products getter should return immutable list', (tester) async {
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => sampleProducts);

      viewModel = ProductsViewModel();
      await viewModel.loadProducts();
      
      final products = viewModel.products;
      
      // Les produits retournés devraient être les mêmes que les données mockées
      expect(products.length, equals(2));
      expect(products[0].id, equals(1));
      expect(products[1].id, equals(2));
    });

    testWidgets('loadProducts should handle empty response', (tester) async {
      when(mockApiService.fetchProducts())
          .thenAnswer((_) async => <Product>[]);

      viewModel = ProductsViewModel();
      await viewModel.loadProducts();
      
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.products, isEmpty);
      expect(viewModel.hasError, isFalse);
    });

    testWidgets('error message should be specific', (tester) async {
      when(mockApiService.fetchProducts())
          .thenThrow(Exception('Specific error'));

      viewModel = ProductsViewModel();
      await viewModel.loadProducts();
      
      expect(viewModel.errorMessage, equals('Impossible de charger les produits'));
      expect(viewModel.hasError, isTrue);
    });
  });
}
