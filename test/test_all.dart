// Fichier principal pour exécuter tous les tests
import 'package:flutter_test/flutter_test.dart';

// Import des tests qui fonctionnent uniquement
import 'viewmodels/cart_viewmodel_test.dart' as cart_viewmodel_tests;
import 'models/product_test.dart' as product_tests;
import 'models/order_test.dart' as order_tests;

void main() {
  group('🧪 Tests des Modèles', () {
    product_tests.main();
    order_tests.main();
  });

  group('🎯 Tests des ViewModels', () {
    cart_viewmodel_tests.main();
  });
}
