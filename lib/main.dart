import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/products_viewmodel.dart';
import 'views/products_page.dart';

void main() {
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
        title: 'Mon App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const ProductsPage(),
        routes: {
          '/products': (context) => const ProductsPage(),
        },
      ),
    );
  }
}