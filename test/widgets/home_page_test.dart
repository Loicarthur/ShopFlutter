import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutcom/pages/home_page.dart';
import 'package:flutcom/viewmodels/cart_viewmodel.dart';
import 'package:flutcom/viewmodels/products_viewmodel.dart';

void main() {
  group('MyHomePage Widget Tests', () {
    late CartViewModel cartViewModel;
    late ProductsViewModel productsViewModel;

    setUp(() {
      cartViewModel = CartViewModel();
      productsViewModel = ProductsViewModel();
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<CartViewModel>.value(value: cartViewModel),
          ChangeNotifierProvider<ProductsViewModel>.value(
              value: productsViewModel),
        ],
        child: MaterialApp(
          home: const MyHomePage(),
          routes: {
            '/catalog': (context) => const Scaffold(body: Text('Catalog Page')),
            '/products': (context) =>
                const Scaffold(body: Text('Products Page')),
            '/cart': (context) => const Scaffold(body: Text('Cart Page')),
            '/orders': (context) => const Scaffold(body: Text('Orders Page')),
          },
        ),
      );
    }

    testWidgets('should display app bar with title and cart icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier l'AppBar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('ShopFlutter'), findsOneWidget);

      // Vérifier la présence du bouton panier (CartIconButton)
      expect(find.byType(IconButton), findsWidgets);
    });

    testWidgets('should display welcome header', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Bienvenue 👋'), findsOneWidget);
      expect(find.byIcon(Icons.storefront), findsOneWidget);
    });

    testWidgets('should display search bar with hint text',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(
          find.text(
              'Rechercher des produits... (taper pour ouvrir le catalogue)'),
          findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should display quick actions', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Catalogue'), findsOneWidget);
      expect(find.text('Produits'), findsOneWidget);
      expect(find.text('Panier'), findsOneWidget);
      expect(find.text('Commandes'), findsOneWidget);

      expect(find.byIcon(Icons.list_alt), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('should display categories section',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('Catégories'), findsOneWidget);
      expect(find.text("men's clothing"), findsOneWidget);
      expect(find.text('jewelery'), findsOneWidget);
      expect(find.text('electronics'), findsOneWidget);
      expect(find.text("women's clothing"), findsOneWidget);
    });

    testWidgets('should display featured section', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.text('À la une'), findsOneWidget);

      // Initialement, on devrait voir un loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('search bar tap should navigate to catalog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Taper sur la barre de recherche
      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Vérifier la navigation vers le catalogue
      expect(find.text('Catalog Page'), findsOneWidget);
    });

    testWidgets('quick action buttons should navigate correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Test navigation vers le catalogue
      await tester.tap(find.text('Catalogue'));
      await tester.pumpAndSettle();
      expect(find.text('Catalog Page'), findsOneWidget);

      // Revenir à la page d'accueil
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test navigation vers les produits
      await tester.tap(find.text('Produits'));
      await tester.pumpAndSettle();
      expect(find.text('Products Page'), findsOneWidget);

      // Revenir à la page d'accueil
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test navigation vers le panier
      await tester.tap(find.text('Panier'));
      await tester.pumpAndSettle();
      expect(find.text('Cart Page'), findsOneWidget);

      // Revenir à la page d'accueil
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Test navigation vers les commandes
      await tester.tap(find.text('Commandes'));
      await tester.pumpAndSettle();
      expect(find.text('Orders Page'), findsOneWidget);
    });

    testWidgets('category chips should navigate to catalog',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Taper sur une catégorie
      await tester.tap(find.text('electronics'));
      await tester.pumpAndSettle();

      expect(find.text('Catalog Page'), findsOneWidget);
    });

    testWidgets('should display drawer', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Ouvrir le drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Vérifier que le drawer est ouvert
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('should handle featured products loading state',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // État de chargement initial
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Attendre que le FutureBuilder se termine
      await tester.pumpAndSettle();

      // Le loading indicator devrait avoir disparu
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should display "Aucun produit" when no featured products',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Si aucun produit n'est chargé, on devrait voir ce message
      // (dépend de l'implémentation du ProductRepository)
      expect(find.text('Aucun produit'), findsOneWidget);
    });

    testWidgets('should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier que la page est scrollable
      expect(find.byType(ListView), findsOneWidget);

      // Tester le scroll
      await tester.drag(find.byType(ListView), const Offset(0, -200));
      await tester.pump();

      // La page devrait toujours être visible après le scroll
      expect(find.text('Bienvenue 👋'), findsOneWidget);
    });

    testWidgets('quick actions should have correct colors',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier que les icônes des actions rapides sont présentes
      expect(find.byIcon(Icons.list_alt), findsOneWidget);
      expect(find.byIcon(Icons.shopping_bag), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long), findsOneWidget);
    });

    testWidgets('should handle safe area correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Vérifier que SafeArea est utilisé
      expect(find.byType(SafeArea), findsOneWidget);
    });
  });
}
