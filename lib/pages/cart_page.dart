import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../viewmodels/products_viewmodel.dart';
import '../models/product.dart';

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
                if (!context.mounted) return;
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
      body: cart.items.isEmpty
          ? _buildEmptyCart(context)
          : Column(
              children: [
                Expanded(child: _buildCartList(cart)),
                _buildSuggestions(context),
              ],
            ),
      bottomNavigationBar:
          cart.items.isNotEmpty ? _buildTotalBar(cart, context) : null,
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
              if (!context.mounted) return;
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
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.product.title} supprimé')),
            );
          },
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                item.product.image,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image_not_supported),
              ),
            ),
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
  Widget _buildTotalBar(CartViewModel cart, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              Text(
                '${cart.totalAmount.toStringAsFixed(2)} €',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              if (!context.mounted) return;
              Navigator.pushNamed(context, '/checkout');
            },
            child: const Text('Procéder au paiement'),
          ),
        ],
      ),
    );
  }

  /// Section des produits suggérés
  Widget _buildSuggestions(BuildContext context) {
    final productsViewModel = context.watch<ProductsViewModel>();
    final suggestions = productsViewModel.products.take(5).toList();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Vous pourriez aimer',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                final product = suggestions[index];
                return _SuggestionCard(product: product);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final Product product;
  const _SuggestionCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartViewModel>(context, listen: false);
    return SizedBox(
      width: 140,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (!context.mounted) return;
            Navigator.pushNamed(
              context,
              '/product/${product.id}',
              arguments: product,
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  width: double.infinity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  product.formattedPrice,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(4),
                child: TextButton(
                  onPressed: () {
                    cart.add(product);
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${product.title} ajouté au panier'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Ajouter'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
