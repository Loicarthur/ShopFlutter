import 'package:flutter_test/flutter_test.dart';
import 'package:vraiauth/viewmodels/cart_viewmodel.dart';
import 'package:vraiauth/models/product.dart';

void main() {
  group('CartItem Tests', () {
    final sampleProduct = Product(
      id: 1,
      title: 'Test Product',
      price: 10.0,
      description: 'Test description',
      category: 'test',
      image: 'test.jpg',
      rating: Rating(rate: 4.0, count: 100),
    );

    test('CartItem constructor should create item with correct properties', () {
      final cartItem = CartItem(product: sampleProduct, quantity: 2);
      
      expect(cartItem.product, equals(sampleProduct));
      expect(cartItem.quantity, equals(2));
    });

    test('CartItem should default to quantity 1', () {
      final cartItem = CartItem(product: sampleProduct);
      
      expect(cartItem.quantity, equals(1));
    });

    test('totalPrice should calculate correctly', () {
      final cartItem = CartItem(product: sampleProduct, quantity: 3);
      
      expect(cartItem.totalPrice, equals(30.0)); // 10.0 * 3
    });

    test('totalPrice should update when quantity changes', () {
      final cartItem = CartItem(product: sampleProduct, quantity: 2);
      
      expect(cartItem.totalPrice, equals(20.0));
      
      cartItem.quantity = 5;
      expect(cartItem.totalPrice, equals(50.0));
    });
  });

  group('CartViewModel Tests', () {
    late CartViewModel cartViewModel;
    late Product product1;
    late Product product2;

    setUp(() {
      cartViewModel = CartViewModel();
      product1 = Product(
        id: 1,
        title: 'Product 1',
        price: 15.0,
        description: 'Description 1',
        category: 'category1',
        image: 'image1.jpg',
        rating: Rating(rate: 4.5, count: 50),
      );
      product2 = Product(
        id: 2,
        title: 'Product 2',
        price: 25.0,
        description: 'Description 2',
        category: 'category2',
        image: 'image2.jpg',
        rating: Rating(rate: 3.8, count: 75),
      );
    });

    test('initial state should be empty', () {
      expect(cartViewModel.items.isEmpty, isTrue);
      expect(cartViewModel.totalAmount, equals(0.0));
      expect(cartViewModel.totalItemsCount, equals(0));
    });

    test('add should add new product to cart', () {
      cartViewModel.add(product1);
      
      expect(cartViewModel.items.length, equals(1));
      expect(cartViewModel.items.first.product, equals(product1));
      expect(cartViewModel.items.first.quantity, equals(1));
      expect(cartViewModel.totalAmount, equals(15.0));
      expect(cartViewModel.totalItemsCount, equals(1));
    });

    test('add should increment quantity for existing product', () {
      cartViewModel.add(product1);
      cartViewModel.add(product1);
      
      expect(cartViewModel.items.length, equals(1));
      expect(cartViewModel.items.first.quantity, equals(2));
      expect(cartViewModel.totalAmount, equals(30.0));
      expect(cartViewModel.totalItemsCount, equals(2));
    });

    test('add should add different products separately', () {
      cartViewModel.add(product1);
      cartViewModel.add(product2);
      
      expect(cartViewModel.items.length, equals(2));
      expect(cartViewModel.totalAmount, equals(40.0)); // 15.0 + 25.0
      expect(cartViewModel.totalItemsCount, equals(2));
    });

    test('remove should remove product completely from cart', () {
      cartViewModel.add(product1);
      cartViewModel.add(product1); // quantity = 2
      cartViewModel.add(product2);
      
      cartViewModel.remove(product1);
      
      expect(cartViewModel.items.length, equals(1));
      expect(cartViewModel.items.first.product, equals(product2));
      expect(cartViewModel.totalAmount, equals(25.0));
      expect(cartViewModel.totalItemsCount, equals(1));
    });

    test('remove should do nothing if product not in cart', () {
      cartViewModel.add(product1);
      
      cartViewModel.remove(product2);
      
      expect(cartViewModel.items.length, equals(1));
      expect(cartViewModel.items.first.product, equals(product1));
    });

    test('removeOne should decrement quantity', () {
      cartViewModel.add(product1);
      cartViewModel.add(product1);
      cartViewModel.add(product1); // quantity = 3
      
      cartViewModel.removeOne(product1);
      
      expect(cartViewModel.items.length, equals(1));
      expect(cartViewModel.items.first.quantity, equals(2));
      expect(cartViewModel.totalAmount, equals(30.0));
      expect(cartViewModel.totalItemsCount, equals(2));
    });

    test('removeOne should remove item when quantity is 1', () {
      cartViewModel.add(product1); // quantity = 1
      
      cartViewModel.removeOne(product1);
      
      expect(cartViewModel.items.isEmpty, isTrue);
      expect(cartViewModel.totalAmount, equals(0.0));
      expect(cartViewModel.totalItemsCount, equals(0));
    });

    test('removeOne should do nothing if product not in cart', () {
      cartViewModel.add(product1);
      
      cartViewModel.removeOne(product2);
      
      expect(cartViewModel.items.length, equals(1));
      expect(cartViewModel.items.first.product, equals(product1));
    });

    test('clear should remove all items', () {
      cartViewModel.add(product1);
      cartViewModel.add(product2);
      cartViewModel.add(product1); // Multiple items
      
      cartViewModel.clear();
      
      expect(cartViewModel.items.isEmpty, isTrue);
      expect(cartViewModel.totalAmount, equals(0.0));
      expect(cartViewModel.totalItemsCount, equals(0));
    });

    test('contains should return true for products in cart', () {
      cartViewModel.add(product1);
      
      expect(cartViewModel.contains(product1), isTrue);
      expect(cartViewModel.contains(product2), isFalse);
    });

    test('items should return unmodifiable list', () {
      cartViewModel.add(product1);
      
      final items = cartViewModel.items;
      
      // Tentative de modification devrait échouer
      expect(() => items.add(CartItem(product: product2)), throwsUnsupportedError);
    });

    test('totalAmount should calculate correctly with multiple items', () {
      cartViewModel.add(product1); // 15.0
      cartViewModel.add(product1); // 15.0 (quantity = 2, total = 30.0)
      cartViewModel.add(product2); // 25.0
      
      expect(cartViewModel.totalAmount, equals(55.0)); // 30.0 + 25.0
    });

    test('totalItemsCount should count all items including quantities', () {
      cartViewModel.add(product1); // quantity = 1
      cartViewModel.add(product1); // quantity = 2
      cartViewModel.add(product1); // quantity = 3
      cartViewModel.add(product2); // quantity = 1
      
      expect(cartViewModel.totalItemsCount, equals(4)); // 3 + 1
    });

    test('ViewModel should notify listeners on state changes', () {
      bool notified = false;
      cartViewModel.addListener(() {
        notified = true;
      });

      cartViewModel.add(product1);
      expect(notified, isTrue);

      notified = false;
      cartViewModel.removeOne(product1);
      expect(notified, isTrue);

      notified = false;
      cartViewModel.clear();
      expect(notified, isTrue);
    });
  });
}
