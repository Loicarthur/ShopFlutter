import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';

class ProductRepository {
  // Récupère tous les produits depuis un JSON local
  Future<List<Product>> fetchProducts() async {
    final data = await rootBundle.loadString('assets/products.json');
    final jsonList = json.decode(data) as List<dynamic>;
    return jsonList
        .map((p) => Product.fromJson(p as Map<String, dynamic>))
        .toList();
  }

  // Récupère un produit par son id
  Future<Product?> fetchProduct(int id) async {
    final products = await fetchProducts();
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      // Retourne null si aucun produit trouvé
      return null;
    }
  }
}
