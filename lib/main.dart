import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// 🔥 Firebase Core
import 'package:firebase_core/firebase_core.dart';

// Tes ViewModels
import 'viewmodels/products_viewmodel.dart';

// Tes pages
import 'views/products_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/catalog_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // ⚡ Indispensable pour Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductsViewModel()),
        // Ajouter d'autres ViewModels ici
      ],
      child: MaterialApp(
        title: 'FlutCom',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),

        // 👇 Page de démarrage
        initialRoute: '/products',

        // 👇 Toutes les routes de l’app
        routes: {
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterPage(),
          '/home': (context) => const MyHomePage(),
          '/products': (context) => const ProductsPage(),
          '/catalog': (context) => const CatalogPage(),
        },

        // 👇 Gestion d’une route inconnue
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
