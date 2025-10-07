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
        '/catalog': (_) =>
            Scaffold(appBar: AppBar(), body: const Text('Catalog')),
        '/products': (_) =>
            Scaffold(appBar: AppBar(), body: const Text('Products')),
        '/cart': (_) => Scaffold(appBar: AppBar(), body: const Text('Cart')),
        '/orders': (_) =>
            Scaffold(appBar: AppBar(), body: const Text('Orders')),
      },
    ),
  );
}

void main() {
  group('HomePage (lib/pages/home_page.dart)', () {
    testWidgets('shows empty state when repo returns empty', (tester) async {
      await tester
          .pumpWidget(_wrapWithProviders(MyHomePage(repo: _FakeRepoEmpty())));
      // initial frame
      await tester.pump();
      // let future resolve
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Aucun produit'), findsOneWidget);
    });

    testWidgets('shows featured list when repo returns data', (tester) async {
      await tester.pumpWidget(
          _wrapWithProviders(MyHomePage(repo: _FakeRepoNonEmpty())));
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

    testWidgets('opens drawer from AppBar menu', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(MyHomePage()));
      await tester.pump();

      final menu = find.byTooltip('Open navigation menu');
      expect(menu, findsOneWidget);
      await tester.tap(menu);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('cart icon navigates to cart', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(MyHomePage()));
      await tester.pump();

      final cartIcon = find.byIcon(Icons.shopping_cart).hitTestable();
      expect(cartIcon, findsOneWidget);
      await tester.tap(cartIcon);
      // Wait for navigation to cart deterministically
      var toCart = false;
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Cart').evaluate().isNotEmpty) {
          toCart = true;
          break;
        }
      }
      expect(toCart, isTrue);
    });

    testWidgets('categories chip navigates to catalog', (tester) async {
      await tester.pumpWidget(_wrapWithProviders(MyHomePage()));
      await tester.pump();

      final chip = find.text('electronics').hitTestable();
      expect(chip, findsOneWidget);
      await tester.tap(chip);
      var toCatalog = false;
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Catalog').evaluate().isNotEmpty) {
          toCatalog = true;
          break;
        }
      }
      expect(toCatalog, isTrue);
    });

    testWidgets('quick actions navigate to Products and Orders',
        (tester) async {
      // Use an empty repo to avoid building featured network images/timers
      await tester
          .pumpWidget(_wrapWithProviders(MyHomePage(repo: _FakeRepoEmpty())));
      await tester.pump();

      // Products
      final prodFinder = find.text('Produits');
      await tester.ensureVisible(prodFinder);
      await tester.tap(prodFinder.hitTestable());
      // Wait for navigation to complete with bounded pumps
      var toProducts = false;
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Products').evaluate().isNotEmpty) {
          toProducts = true;
          break;
        }
      }
      expect(toProducts, isTrue);

      // Back then Orders
      await tester.pageBack();
      await tester.pump(const Duration(milliseconds: 200));
      final ordersFinder = find.text('Commandes');
      await tester.ensureVisible(ordersFinder);
      await tester.tap(ordersFinder.hitTestable());
      var toOrders = false;
      for (var i = 0; i < 12; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Orders').evaluate().isNotEmpty) {
          toOrders = true;
          break;
        }
      }
      expect(toOrders, isTrue);
    });
  });
}
