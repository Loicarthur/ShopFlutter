import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutcom/pages/home_page.dart';
import 'package:flutcom/repositories/product_repository.dart';
import 'package:flutcom/models/product.dart';
import 'package:flutcom/viewmodels/products_viewmodel.dart';
import 'package:flutcom/viewmodels/cart_viewmodel.dart';

class _FakeRepoNonEmpty extends ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async => [
        Product(
          id: 1,
          title: 'A',
          price: 10,
          description: 'd',
          category: 'c',
          image: 'https://example.com/img.png',
          rating: Rating(rate: 4.5, count: 10),
        ),
      ];
}

class _FakeRepoEmpty extends ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async => [];
}

Widget _wrapWithProviders(Widget child) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProductsViewModel()),
      ChangeNotifierProvider(create: (_) => CartViewModel()),
    ],
    child: MaterialApp(
      home: child,
      routes: {
        '/catalog': (_) => const Scaffold(body: Text('Catalog')),
        '/products': (_) => const Scaffold(body: Text('Products')),
        '/cart': (_) => const Scaffold(body: Text('Cart')),
        '/orders': (_) => const Scaffold(body: Text('Orders')),
      },
    ),
  );
}

void main() {
  group('HomePage (lib/pages/home_page.dart)', () {
    testWidgets('shows empty state when repo returns empty', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(MyHomePage(repo: _FakeRepoEmpty())));
      // initial frame
      await tester.pump();
      // let future resolve
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aucun produit'), findsOneWidget);
    });

    testWidgets('shows featured list when repo returns data', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(MyHomePage(repo: _FakeRepoNonEmpty())));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Should not show empty message
      expect(find.text('Aucun produit'), findsNothing);
      // Title visible
      expect(find.text('À la une'), findsOneWidget);
    });

    testWidgets('quick actions navigate', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(MyHomePage()));
      await tester.pump();

      // Tap the visible label of the 'Catalogue' action
      final label = find.text('Catalogue').hitTestable();
      expect(label, findsOneWidget);
      await tester.ensureVisible(label);
      await tester.tap(label);

      // Allow navigation to complete with limited pumps
      var found = false;
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Catalog').evaluate().isNotEmpty) {
          found = true;
          break;
        }
      }
      expect(found, isTrue);
    });
  });
}
