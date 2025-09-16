import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // État privé
  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters publics (lecture seule)
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Chargement automatique à l'instanciation
  ProductsViewModel() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    // Éviter les appels multiples simultanés
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      _products = await _apiService.fetchProducts();
    } catch (error) {
      _setError('Impossible de charger les produits');
    }

    _setLoading(false);
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
    _errorMessage = '';
    notifyListeners();
  }
}