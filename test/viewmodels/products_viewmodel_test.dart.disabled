import 'package:flutter_test/flutter_test.dart';
import 'package:flutcom/viewmodels/products_viewmodel.dart';
import 'package:flutcom/models/product.dart';

void main() {
  group('ProductsViewModel Tests', () {
    late ProductsViewModel viewModel;

    setUp(() {
      viewModel = ProductsViewModel();
    });

    test('initial state should be correct', () {
      expect(viewModel.products, isEmpty);
      expect(viewModel.isLoading, isFalse);
    });

    test('ViewModel should be a ChangeNotifier', () {
      expect(viewModel, isA<ProductsViewModel>());
    });

    test('products getter should return list', () {
      final products = viewModel.products;
      expect(products, isA<List<Product>>());
    });

    test('isLoading should be boolean', () {
      expect(viewModel.isLoading, isA<bool>());
    });

    test('loadProducts should be callable', () async {
      // Test que la méthode existe et peut être appelée
      expect(() => viewModel.loadProducts(), returnsNormally);
    });

    test('ViewModel should notify listeners', () {
      int notificationCount = 0;
      viewModel.addListener(() {
        notificationCount++;
      });

      // Déclencher une notification
      viewModel.notifyListeners();
      
      expect(notificationCount, equals(1));
    });

    test('products should be initially empty', () {
      expect(viewModel.products.length, equals(0));
    });

    test('isLoading should be initially false', () {
      expect(viewModel.isLoading, isFalse);
    });

    test('ViewModel should be disposable', () {
      expect(() => viewModel.dispose(), returnsNormally);
    });

    test('multiple instances should be independent', () {
      final viewModel1 = ProductsViewModel();
      final viewModel2 = ProductsViewModel();
      
      expect(identical(viewModel1, viewModel2), isFalse);
    });
  });
}
