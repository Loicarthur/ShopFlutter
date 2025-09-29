import 'package:flutter_test/flutter_test.dart';
import 'package:vraiauth/models/order.dart';
import 'package:vraiauth/models/product.dart';

void main() {
  group('OrderItem Model Tests', () {
    // Données de test
    final sampleProduct = Product(
      id: 1,
      title: 'Test Product',
      price: 25.99,
      description: 'A test product',
      category: 'electronics',
      image: 'https://example.com/image.jpg',
      rating: Rating(rate: 4.5, count: 100),
    );

    final sampleOrderItem = OrderItem(
      productId: 1,
      title: 'Test Product',
      image: 'https://example.com/image.jpg',
      unitPrice: 25.99,
      quantity: 2,
    );

    test('OrderItem constructor should create order item with correct properties', () {
      expect(sampleOrderItem.productId, equals(1));
      expect(sampleOrderItem.title, equals('Test Product'));
      expect(sampleOrderItem.image, equals('https://example.com/image.jpg'));
      expect(sampleOrderItem.unitPrice, equals(25.99));
      expect(sampleOrderItem.quantity, equals(2));
    });

    test('lineTotal should calculate correctly', () {
      expect(sampleOrderItem.lineTotal, equals(51.98));
      
      // Test avec quantité 1
      final singleItem = OrderItem(
        productId: 2,
        title: 'Single Item',
        image: 'test.jpg',
        unitPrice: 10.0,
        quantity: 1,
      );
      expect(singleItem.lineTotal, equals(10.0));
      
      // Test avec quantité 0
      final zeroItem = OrderItem(
        productId: 3,
        title: 'Zero Item',
        image: 'test.jpg',
        unitPrice: 15.0,
        quantity: 0,
      );
      expect(zeroItem.lineTotal, equals(0.0));
    });

    test('OrderItem.fromProduct should create order item from product', () {
      final orderItem = OrderItem.fromProduct(sampleProduct, 3);
      
      expect(orderItem.productId, equals(sampleProduct.id));
      expect(orderItem.title, equals(sampleProduct.title));
      expect(orderItem.image, equals(sampleProduct.image));
      expect(orderItem.unitPrice, equals(sampleProduct.price));
      expect(orderItem.quantity, equals(3));
      expect(orderItem.lineTotal, equals(77.97)); // 25.99 * 3
    });

    test('OrderItem toJson should serialize correctly', () {
      final json = sampleOrderItem.toJson();
      
      expect(json['productId'], equals(1));
      expect(json['title'], equals('Test Product'));
      expect(json['image'], equals('https://example.com/image.jpg'));
      expect(json['unitPrice'], equals(25.99));
      expect(json['quantity'], equals(2));
    });

    test('OrderItem.fromJson should deserialize correctly', () {
      final json = {
        'productId': 1,
        'title': 'Test Product',
        'image': 'https://example.com/image.jpg',
        'unitPrice': 25.99,
        'quantity': 2,
      };
      
      final orderItem = OrderItem.fromJson(json);
      
      expect(orderItem.productId, equals(1));
      expect(orderItem.title, equals('Test Product'));
      expect(orderItem.image, equals('https://example.com/image.jpg'));
      expect(orderItem.unitPrice, equals(25.99));
      expect(orderItem.quantity, equals(2));
    });

    test('OrderItem JSON serialization roundtrip should work', () {
      final json = sampleOrderItem.toJson();
      final deserializedItem = OrderItem.fromJson(json);
      
      expect(deserializedItem.productId, equals(sampleOrderItem.productId));
      expect(deserializedItem.title, equals(sampleOrderItem.title));
      expect(deserializedItem.image, equals(sampleOrderItem.image));
      expect(deserializedItem.unitPrice, equals(sampleOrderItem.unitPrice));
      expect(deserializedItem.quantity, equals(sampleOrderItem.quantity));
      expect(deserializedItem.lineTotal, equals(sampleOrderItem.lineTotal));
    });
  });

  group('Order Model Tests', () {
    final sampleOrderItems = [
      OrderItem(
        productId: 1,
        title: 'Product 1',
        image: 'image1.jpg',
        unitPrice: 10.0,
        quantity: 2,
      ),
      OrderItem(
        productId: 2,
        title: 'Product 2',
        image: 'image2.jpg',
        unitPrice: 15.0,
        quantity: 1,
      ),
    ];

    final sampleOrder = Order(
      id: 'order-123',
      createdAt: DateTime(2024, 1, 15, 10, 30),
      items: sampleOrderItems,
      totalAmount: 35.0,
    );

    test('Order constructor should create order with correct properties', () {
      expect(sampleOrder.id, equals('order-123'));
      expect(sampleOrder.createdAt, equals(DateTime(2024, 1, 15, 10, 30)));
      expect(sampleOrder.items.length, equals(2));
      expect(sampleOrder.totalAmount, equals(35.0));
    });

    test('Order toJson should serialize correctly', () {
      final json = sampleOrder.toJson();
      
      expect(json['id'], equals('order-123'));
      expect(json['createdAt'], equals('2024-01-15T10:30:00.000'));
      expect(json['items'], isA<List>());
      expect(json['items'].length, equals(2));
      expect(json['totalAmount'], equals(35.0));
      
      // Vérifier le premier item
      final firstItem = json['items'][0];
      expect(firstItem['productId'], equals(1));
      expect(firstItem['title'], equals('Product 1'));
    });

    test('Order.fromJson should deserialize correctly', () {
      final json = {
        'id': 'order-456',
        'createdAt': '2024-02-20T14:45:30.000',
        'items': [
          {
            'productId': 3,
            'title': 'Product 3',
            'image': 'image3.jpg',
            'unitPrice': 20.0,
            'quantity': 1,
          }
        ],
        'totalAmount': 20.0,
      };
      
      final order = Order.fromJson(json);
      
      expect(order.id, equals('order-456'));
      expect(order.createdAt, equals(DateTime(2024, 2, 20, 14, 45, 30)));
      expect(order.items.length, equals(1));
      expect(order.items[0].productId, equals(3));
      expect(order.items[0].title, equals('Product 3'));
      expect(order.totalAmount, equals(20.0));
    });

    test('Order JSON serialization roundtrip should work', () {
      final json = sampleOrder.toJson();
      final deserializedOrder = Order.fromJson(json);
      
      expect(deserializedOrder.id, equals(sampleOrder.id));
      expect(deserializedOrder.createdAt, equals(sampleOrder.createdAt));
      expect(deserializedOrder.items.length, equals(sampleOrder.items.length));
      expect(deserializedOrder.totalAmount, equals(sampleOrder.totalAmount));
      
      // Vérifier les items
      for (int i = 0; i < sampleOrder.items.length; i++) {
        final original = sampleOrder.items[i];
        final deserialized = deserializedOrder.items[i];
        
        expect(deserialized.productId, equals(original.productId));
        expect(deserialized.title, equals(original.title));
        expect(deserialized.image, equals(original.image));
        expect(deserialized.unitPrice, equals(original.unitPrice));
        expect(deserialized.quantity, equals(original.quantity));
      }
    });

    test('Order with empty items should work', () {
      final emptyOrder = Order(
        id: 'empty-order',
        createdAt: DateTime.now(),
        items: [],
        totalAmount: 0.0,
      );
      
      expect(emptyOrder.items.isEmpty, isTrue);
      expect(emptyOrder.totalAmount, equals(0.0));
      
      // Test de sérialisation
      final json = emptyOrder.toJson();
      final deserializedOrder = Order.fromJson(json);
      
      expect(deserializedOrder.items.isEmpty, isTrue);
      expect(deserializedOrder.totalAmount, equals(0.0));
    });
  });
}
