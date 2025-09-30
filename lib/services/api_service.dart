import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String baseUrl = 'https://fakestoreapi.com';

  final http.Client client;

  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    final response = await client
        .get(
          Uri.parse('$baseUrl/products'),
          headers: const {'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}: failed to fetch products');
    }

    final body = response.body.trim();
    if (body.isEmpty) {
      return <Product>[]; // empty response -> empty list
    }

    final decoded = json.decode(body);
    if (decoded is! List) {
      throw const FormatException('Invalid JSON: expected a list');
    }
    return decoded.map<Product>((json) => Product.fromJson(json)).toList();
  }
}
