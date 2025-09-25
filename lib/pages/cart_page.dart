import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          if (cart.items.isNotEmpty)
            TextButton(
              onPressed: () {
                cart.clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Panier vidé')),
                );
              },
              child: const Text(
                'Vider',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body:
          cart.items.isEmpty ? _buildEmptyCart(context) : _buildCartList(cart),
      bottomNavigationBar: cart.items.isNotEmpty ? _buildTotalBar(cart) : null,
    );
  }

  /// Widget affiché lorsque le panier est vide
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Votre panier est vide',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/products');
            },
            child: const Text('Retour aux produits'),
          ),
        ],
      ),
    );
  }

  /// Liste des articles du panier
  Widget _buildCartList(CartViewModel cart) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: cart.items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = cart.items[index];

        return Dismissible(
          key: Key(item.product.id.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) {
            cart.remove(item.product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.product.title} supprimé')),
            );
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(item.product.title),
            subtitle: Text('Qté: ${item.quantity}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => cart.removeOne(item.product),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => cart.add(item.product),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Barre de total en bas
  Widget _buildTotalBar(CartViewModel cart) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey[200],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${cart.totalAmount.toStringAsFixed(2)} €',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
