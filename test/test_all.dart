// Fichier principal pour exécuter tous les tests
import 'package:flutter_test/flutter_test.dart';

// Import de tous les tests
import 'models/product_test.dart' as product_tests;
import 'models/order_test.dart' as order_tests;
import 'viewmodels/cart_viewmodel_test.dart' as cart_viewmodel_tests;
import 'viewmodels/products_viewmodel_test.dart' as products_viewmodel_tests;
import 'services/api_service_test.dart' as api_service_tests;
import 'services/auth_service_test.dart' as auth_service_tests;
import 'widgets/home_page_test.dart' as home_page_tests;

void main() {
  group('🧪 Tests des Modèles', () {
    product_tests.main();
    order_tests.main();
  });

  group('🎯 Tests des ViewModels', () {
    cart_viewmodel_tests.main();
    products_viewmodel_tests.main();
  });

  group('🔧 Tests des Services', () {
    api_service_tests.main();
    auth_service_tests.main();
  });

  group('🎨 Tests des Widgets', () {
    home_page_tests.main();
  });
}
