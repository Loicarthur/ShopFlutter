import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutcom/services/api_service.dart';
import 'package:flutcom/models/product.dart';

void main() {
  group('ApiService.fetchProducts()', () {
    test('returns products on 200 with valid JSON list', () async {
      final mock = MockClient((request) async {
        expect(request.url.toString(), '${ApiService.baseUrl}/products');
        expect(request.headers['Content-Type'], 'application/json');
        final body = [
          {
            'id': 1,
            'title': 'A',
            'price': 10.0,
            'description': 'd',
            'category': 'c',
            'image': 'https://example.com/img.png',
            'rating': {'rate': 4.5, 'count': 10}
          }
        ];
        return http.Response(ProductTestUtils.encode(body), 200,
            headers: {'content-type': 'application/json'});
      });
      final api = ApiService(client: mock);
      final result = await api.fetchProducts();
      expect(result, isA<List<Product>>());
      expect(result.length, 1);
      expect(result.first.title, 'A');
    });

    test('throws on non-200 status', () async {
      final mock = MockClient((_) async => http.Response('err', 500));
      final api = ApiService(client: mock);
      expect(() => api.fetchProducts(), throwsA(isA<Exception>()));
    });

    test('propagates TimeoutException from client', () async {
      final mock = MockClient((_) async => throw TimeoutException('boom'));
      final api = ApiService(client: mock);
      expect(() => api.fetchProducts(), throwsA(isA<TimeoutException>()));
    });

    test('throws FormatException on invalid JSON (not a list)', () async {
      final mock = MockClient((_) async => http.Response('{"a":1}', 200));
      final api = ApiService(client: mock);
      expect(() => api.fetchProducts(), throwsA(isA<FormatException>()));
    });

    test('returns empty list on empty body', () async {
      final mock = MockClient((_) async => http.Response('   ', 200));
      final api = ApiService(client: mock);
      final result = await api.fetchProducts();
      expect(result, isEmpty);
    });
  });
}

class ProductTestUtils {
  static String encode(Object body) =>
      body is String ? body : _jsonEncode(body);
}

String _jsonEncode(Object? value) => const JsonEncoder().convert(value);
