// Fichier principal pour exécuter tous les tests
import 'package:flutter_test/flutter_test.dart';

// Import des tests existants uniquement
import 'viewmodels/cart_viewmodel_test.dart' as cart_viewmodel_tests;
import 'viewmodels/products_viewmodel_test.dart' as products_viewmodel_tests;
import 'widgets/home_page_test.dart' as home_page_tests;

void main() {
  group('🎯 Tests des ViewModels', () {
    cart_viewmodel_tests.main();
    products_viewmodel_tests.main();
  });

  group('🎨 Tests des Widgets', () {
    home_page_tests.main();
  });
}
