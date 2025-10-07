import 'package:flutter_test/flutter_test.dart';
import 'package:flutcom/viewmodels/products_viewmodel.dart';
import 'package:flutcom/services/api_service.dart';
import 'package:flutcom/models/product.dart';

class _FakeApiSuccess extends ApiService {
  _FakeApiSuccess() : super();
  @override
  Future<List<Product>> fetchProducts() async {
    return [
      Product(
        id: 1,
        title: 'A',
        price: 10,
        description: 'd',
        category: 'c',
        image: 'https://example.com/a.png',
        rating: Rating(rate: 4.5, count: 10),
      ),
    ];
  }
}

class _FakeApiEmpty extends ApiService {
  _FakeApiEmpty() : super();
  @override
  Future<List<Product>> fetchProducts() async => [];
}

class _FakeApiError extends ApiService {
  _FakeApiError() : super();
  @override
  Future<List<Product>> fetchProducts() async => throw Exception('boom');
}

void main() {
  group('ProductsViewModel', () {
    test('loads products successfully and updates state', () async {
      final vm = ProductsViewModel(apiService: _FakeApiSuccess());
      // constructor triggers loadProducts(); wait for async to complete
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isFalse);
      expect(vm.products, isNotEmpty);
      expect(vm.products.first.title, 'A');
    });

    test('handles empty response', () async {
      final vm = ProductsViewModel(apiService: _FakeApiEmpty());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isFalse);
      expect(vm.products, isEmpty);
    });

    test('handles error and sets errorMessage', () async {
      final vm = ProductsViewModel(apiService: _FakeApiError());
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(vm.isLoading, isFalse);
      expect(vm.hasError, isTrue);
      expect(vm.errorMessage, isNotEmpty);
      expect(vm.products, isEmpty);
    });

    test('does not re-enter loadProducts while already loading', () async {
      final vm = ProductsViewModel(apiService: _FakeApiSuccess());
      // Immediately try to call loadProducts again while it may still be loading
      vm.loadProducts();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      // Rely on state correctness
      expect(vm.isLoading, isFalse);
      expect(vm.products.length, 1);
    });
  });
}
