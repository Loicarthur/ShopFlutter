import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _go(BuildContext context, String route) {
    // Ferme le drawer puis remplace la route courante pour éviter d'empiler
    Navigator.pop(context);
    final current = ModalRoute.of(context)?.settings.name;
    if (current == route) return;
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: 140,
              padding: const EdgeInsets.all(16),
              alignment: Alignment.bottomLeft,
              decoration: const BoxDecoration(color: Colors.blue),
              child: const Text(
                'Drawer Header',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () => _go(context, '/home'),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.orange),
              title: const Text('Produits'),
              onTap: () => _go(context, '/products'),
            ),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.indigo),
              title: const Text('Mes commandes'),
              onTap: () => _go(context, '/orders'),
            ),
            ListTile(
              leading: const Icon(Icons.login, color: Colors.green),
              title: const Text('Se connecter'),
              onTap: () => _go(context, '/login'),
            ),
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.blue),
              title: const Text('S\'inscrire'),
              onTap: () => _go(context, '/register'),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Déconnexion'),
              onTap: () async {
                final navigator = Navigator.of(context);
                await FirebaseAuth.instance.signOut();
                navigator.pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
