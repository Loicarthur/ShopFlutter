import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart'; // FlutterFire CLI

// ViewModels
import 'viewmodels/products_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart'; // <-- ajouté

// Pages
import 'views/products_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/catalog_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/orders_page.dart';
import 'models/product.dart';
import 'dart:io' show Platform;

// ⚡ Classe utilitaire pour détecter l'OS de façon sécurisée
class PlatformUtils {
  static String get operatingSystem {
    if (kIsWeb) return "Web";
    if (Platform.isAndroid) return "Android";
    if (Platform.isIOS) return "iOS";
    if (Platform.isWindows) return "Windows";
    if (Platform.isMacOS) return "macOS";
    if (Platform.isLinux) return "Linux";
    return "Unknown";
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Initialisation Firebase selon la plateforme
  await Firebase.initializeApp(
    options: kIsWeb
        ? DefaultFirebaseOptions.web
        : DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        ChangeNotifierProvider(create: (_) => CartViewModel()), // <-- ajouté
      ],
      child: MaterialApp(
        title: 'FlutCom',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

        // Page de démarrage
        home: const MyHomePage(),

        // Routes statiques
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const MyHomePage(),
          '/products': (context) => const ProductsPage(),
          '/catalog': (context) => const CatalogPage(),
          '/orders': (context) => const OrdersPage(),
        },

        // Routes dynamiques pour les détails produit
        onGenerateRoute: (settings) {
          final name = settings.name ?? '';
          final productMatch = RegExp(r'^/product/(\d+)$').firstMatch(name);
          if (productMatch != null) {
            final id = int.parse(productMatch.group(1)!);
            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(
                productId: id,
                product: settings.arguments is Product
                    ? settings.arguments as Product
                    : null,
              ),
              settings: settings,
            );
          }
          return null;
        },

        // Route inconnue
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              body: Center(
                child: Text("Route inconnue : ${settings.name}"),
              ),
            ),
          );
        },
      ),
    );
  }
}
