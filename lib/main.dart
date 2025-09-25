import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart'; // FlutterFire CLI

// ViewModels
import 'viewmodels/products_viewmodel.dart';
import 'viewmodels/cart_viewmodel.dart';

// Pages
import 'views/products_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/catalog_page.dart';
import 'pages/product_detail_page.dart';
import 'pages/orders_page.dart';
import 'pages/cart_page.dart';
import 'models/product.dart';

// ⚡ Détection de plateforme sécurisée
// Import conditionnel pour dart:io uniquement si ce n’est pas le web
// ignore: dart.library.io
import 'dart:io' show Platform;

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
        ChangeNotifierProvider(create: (_) => CartViewModel()),
      ],
      child: MaterialApp(
        title: 'FlutCom',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const MyHomePage(),
        routes: {
          '/login': (_) => const LoginPage(),
          '/register': (_) => const RegisterPage(),
          '/home': (_) => const MyHomePage(),
          '/products': (_) => const ProductsPage(),
          '/catalog': (_) => const CatalogPage(),
          '/orders': (_) => const OrdersPage(),
          '/cart': (_) => const CartPage(), // ← Ajout de la route panier
        },
        onGenerateRoute: (settings) {
          final name = settings.name ?? '';
          final match = RegExp(r'^/product/(\d+)$').firstMatch(name);

          if (match != null) {
            final id = int.parse(match.group(1)!);
            final product = settings.arguments is Product
                ? settings.arguments as Product
                : null;

            return MaterialPageRoute(
              builder: (_) => ProductDetailPage(
                productId: id,
                product: product,
              ),
              settings: settings,
            );
          }

          return null;
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text("Route inconnue : ${settings.name}"),
            ),
          ),
        ),
      ),
    );
  }
}
