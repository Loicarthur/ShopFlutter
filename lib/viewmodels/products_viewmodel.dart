import 'dart:collection';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsViewModel extends ChangeNotifier {
  final ApiService _apiService;

  // État privé
  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters publics (lecture seule)
  UnmodifiableListView<Product> get products => UnmodifiableListView(_products);
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Pas de chargement automatique pour faciliter les tests et le contrôle
  ProductsViewModel({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  Future<void> loadProducts() async {
    // Éviter les appels multiples simultanés
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      final fetched = await _apiService.fetchProducts();
      _products = List<Product>.unmodifiable(fetched);
      notifyListeners();
    } catch (error) {
      _setError('Impossible de charger les produits: ${error.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Méthodes privées pour gérer l'état
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage.isEmpty) return;
    _errorMessage = '';
    notifyListeners();
  }
}
