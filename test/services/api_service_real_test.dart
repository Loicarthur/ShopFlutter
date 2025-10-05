import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutcom/services/api_service.dart';
import 'package:flutcom/models/product.dart';

void main() {
  group('ApiService.fetchProducts', () {
    test('returns list on 200 with valid JSON', () async {
      final sample = [
        {
          'id': 1,
          'title': 'P1',
          'price': 10.0,
          'description': 'd',
          'category': 'c',
          'image': 'u',
          'rating': {'rate': 4.5, 'count': 10}
        },
        {
          'id': 2,
          'title': 'P2',
          'price': 12.0,
          'description': 'd',
          'category': 'c',
          'image': 'u',
          'rating': {'rate': 4.0, 'count': 5}
        },
      ];
      final client = MockClient((request) async => http.Response(jsonEncode(sample), 200,
          headers: {'Content-Type': 'application/json'}));
      final api = ApiService(client: client);

      final list = await api.fetchProducts();
      expect(list, isA<List<Product>>());
      expect(list.length, 2);
      expect(list.first.title, 'P1');
    });

    test('throws on non-200', () async {
      final client = MockClient((request) async => http.Response('err', 500));
      final api = ApiService(client: client);
      expect(api.fetchProducts(), throwsA(isA<Exception>()));
    });

    test('returns empty list on empty body', () async {
      final client = MockClient((request) async => http.Response('', 200));
      final api = ApiService(client: client);
      final list = await api.fetchProducts();
      expect(list, isEmpty);
    });

    test('throws FormatException on invalid JSON shape', () async {
      final client = MockClient((request) async => http.Response('{}', 200,
          headers: {'Content-Type': 'application/json'}));
      final api = ApiService(client: client);
      expect(api.fetchProducts(), throwsA(isA<FormatException>()));
    });
  });
}
