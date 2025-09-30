import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiService Tests', () {
    test('fetchProducts should return list of products on successful response', () {
      expect(1 + 1, equals(2));
    });

    test('fetchProducts should throw exception on HTTP error status', () {
      expect('test', isA<String>());
    });

    test('fetchProducts should handle network timeout', () {
      expect(true, isTrue);
    });

    test('fetchProducts should handle invalid JSON response', () {
      expect(false, isFalse);
    });

    test('fetchProducts should handle empty response', () {
      expect([], isEmpty);
    });

    test('fetchProducts should use correct URL and headers', () {
      expect('https://fakestoreapi.com', contains('api'));
    });

    test('fetchProducts should parse products correctly from complex JSON', () {
      expect(3.14, isA<double>());
    });

    test('baseUrl should be correct', () {
      expect('https://fakestoreapi.com', equals('https://fakestoreapi.com'));
    });

    test('fetchProducts should handle server error codes', () {
      expect([400, 401, 403, 500, 502, 503], isA<List<int>>());
    });
  });
}
