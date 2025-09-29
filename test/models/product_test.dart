import 'package:flutter_test/flutter_test.dart';
import 'package:vraiauth/models/product.dart';

void main() {
  group('Product Model Tests', () {
    // Données de test
    final Map<String, dynamic> sampleProductJson = {
      'id': 1,
      'title': 'Test Product',
      'price': 29.99,
      'description': 'A test product description',
      'category': 'electronics',
      'image': 'https://example.com/image.jpg',
      'rating': {
        'rate': 4.5,
        'count': 120
      }
    };

    final sampleRating = Rating(rate: 4.5, count: 120);
    final sampleProduct = Product(
      id: 1,
      title: 'Test Product',
      price: 29.99,
      description: 'A test product description',
      category: 'electronics',
      image: 'https://example.com/image.jpg',
      rating: sampleRating,
    );

    test('Product constructor should create product with correct properties', () {
      expect(sampleProduct.id, equals(1));
      expect(sampleProduct.title, equals('Test Product'));
      expect(sampleProduct.price, equals(29.99));
      expect(sampleProduct.description, equals('A test product description'));
      expect(sampleProduct.category, equals('electronics'));
      expect(sampleProduct.image, equals('https://example.com/image.jpg'));
      expect(sampleProduct.rating.rate, equals(4.5));
      expect(sampleProduct.rating.count, equals(120));
    });

    test('Product.fromJson should create product from JSON correctly', () {
      final product = Product.fromJson(sampleProductJson);
      
      expect(product.id, equals(1));
      expect(product.title, equals('Test Product'));
      expect(product.price, equals(29.99));
      expect(product.description, equals('A test product description'));
      expect(product.category, equals('electronics'));
      expect(product.image, equals('https://example.com/image.jpg'));
      expect(product.rating.rate, equals(4.5));
      expect(product.rating.count, equals(120));
    });

    test('formattedPrice should return correctly formatted price', () {
      expect(sampleProduct.formattedPrice, equals('29.99 €'));
      
      // Test avec un prix entier
      final productWithIntPrice = Product(
        id: 2,
        title: 'Test Product 2',
        price: 30.0,
        description: 'Test',
        category: 'test',
        image: 'test.jpg',
        rating: sampleRating,
      );
      expect(productWithIntPrice.formattedPrice, equals('30.00 €'));
    });

    test('starsDisplay should return correctly formatted rating display', () {
      expect(sampleProduct.starsDisplay, equals('⭐ 4.5 (120)'));
      
      // Test avec une note arrondie
      final productWithRoundRating = Product(
        id: 3,
        title: 'Test Product 3',
        price: 25.0,
        description: 'Test',
        category: 'test',
        image: 'test.jpg',
        rating: Rating(rate: 3.0, count: 50),
      );
      expect(productWithRoundRating.starsDisplay, equals('⭐ 3.0 (50)'));
    });

    test('Product.fromJson should handle different number types for price', () {
      // Test avec un int pour le prix
      final jsonWithIntPrice = Map<String, dynamic>.from(sampleProductJson);
      jsonWithIntPrice['price'] = 30;
      
      final product = Product.fromJson(jsonWithIntPrice);
      expect(product.price, equals(30.0));
      expect(product.price, isA<double>());
    });
  });

  group('Rating Model Tests', () {
    test('Rating constructor should create rating with correct properties', () {
      final rating = Rating(rate: 4.2, count: 85);
      
      expect(rating.rate, equals(4.2));
      expect(rating.count, equals(85));
    });

    test('Rating.fromJson should create rating from JSON correctly', () {
      final ratingJson = {
        'rate': 3.8,
        'count': 200
      };
      
      final rating = Rating.fromJson(ratingJson);
      
      expect(rating.rate, equals(3.8));
      expect(rating.count, equals(200));
    });

    test('Rating.fromJson should handle different number types', () {
      // Test avec un int pour rate
      final ratingJson = {
        'rate': 4,
        'count': 150
      };
      
      final rating = Rating.fromJson(ratingJson);
      
      expect(rating.rate, equals(4.0));
      expect(rating.rate, isA<double>());
      expect(rating.count, equals(150));
    });
  });
}
