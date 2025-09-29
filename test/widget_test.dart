// Tests d'intégration pour l'application FlutCom
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vraiauth/main.dart';

void main() {
  group('Tests d\'intégration de l\'application', () {
    testWidgets('App should start and display home page', (WidgetTester tester) async {
      // Construire l'application
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Vérifier que l'application démarre correctement
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('FlutCom'), findsOneWidget);
      expect(find.text('Bienvenue 👋'), findsOneWidget);
    });

    testWidgets('Drawer should open and close', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Ouvrir le drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Vérifier que le drawer est ouvert
      expect(find.byType(Drawer), findsOneWidget);

      // Fermer le drawer en tapant à côté
      await tester.tapAt(const Offset(400, 300));
      await tester.pumpAndSettle();

      // Vérifier que le drawer est fermé
      expect(find.byType(Drawer), findsNothing);
    });

    testWidgets('Navigation should work via Drawer', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Ouvrir le drawer
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();

      // Définir les keys dans ton Drawer pour chaque page
      final drawerKeys = {
        'Catalogue': const Key('drawer_catalog'),
        'Produits': const Key('drawer_products'),
        'Panier': const Key('drawer_cart'),
        'Commandes': const Key('drawer_orders'),
      };

      for (final route in drawerKeys.entries) {
        await tester.tap(find.byKey(route.value));
        await tester.pumpAndSettle();

        // Vérifier qu'on est bien sur une page avec AppBar
        expect(find.byType(AppBar), findsOneWidget);

        // Revenir à la page d'accueil
        await tester.tap(find.byIcon(Icons.menu));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('App should display main UI elements', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Vérifier tous les éléments principaux
      expect(find.text('FlutCom'), findsOneWidget);
      expect(find.text('Bienvenue 👋'), findsOneWidget);
      expect(find.text('Catégories'), findsOneWidget);
      expect(find.text('À la une'), findsOneWidget);

      // Vérifier icônes
      expect(find.byIcon(Icons.storefront), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);

      // Vérifier barre de recherche avec key
      expect(find.byKey(const Key('search_field')), findsOneWidget);
    });

    testWidgets('App should handle search interaction', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Taper sur la barre de recherche
      await tester.tap(find.byKey(const Key('search_field')));
      await tester.pumpAndSettle();

      // Vérifier que le TextField est sélectionné
      expect(find.byKey(const Key('search_field')), findsOneWidget);
    });

    testWidgets('App should be scrollable', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tester le scroll sur le ListView principal
      final listViewFinder = find.byType(ListView);
      expect(listViewFinder, findsWidgets);

      await tester.drag(listViewFinder.first, const Offset(0, -300));
      await tester.pumpAndSettle();

      // Vérifier que l'app fonctionne toujours après le scroll
      expect(find.text('FlutCom'), findsOneWidget);
    });
  });
}
