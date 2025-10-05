import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductsViewModel extends ChangeNotifier {
  // La dépendance est déclarée mais pas instanciée ici.
  final ApiService apiService;

  // État privé
  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters publics (lecture seule)
  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  bool get hasError => _errorMessage.isNotEmpty;

  // Le constructeur accepte maintenant un ApiService.
  // Si aucun n'est fourni, il en crée un par défaut.
  ProductsViewModel({ApiService? apiService})
      : apiService = apiService ?? ApiService() {
    loadProducts();
  }

  Future<void> loadProducts() async {
    if (_isLoading) return;

    _setLoading(true);
    _clearError();

    try {
      // On utilise l'instance fournie (réelle ou mockée).
      _products = await apiService.fetchProducts();
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
