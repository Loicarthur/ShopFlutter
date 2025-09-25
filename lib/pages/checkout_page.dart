import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _processing = false;
  String _selectedPayment = 'Carte bancaire';
  final OrderRepository _orderRepo = OrderRepository();

  // Simuler un paiement
  Future<bool> _mockPayment() async {
    await Future.delayed(const Duration(seconds: 2));
    return true; // paiement réussi
  }

  // Création de la commande localement
  Future<void> _createLocalOrder(CartViewModel cart) async {
    final items = cart.items
        .map((ci) => OrderItem.fromProduct(ci.product, ci.quantity))
        .toList();

    final order = Order(
      id: const Uuid().v4(),
      createdAt: DateTime.now(),
      items: items,
      totalAmount: cart.totalAmount,
    );

    await _orderRepo.addOrder(order);
    cart.clear();
  }

  Future<void> _handlePayment(CartViewModel cart) async {
    if (cart.items.isEmpty) return;

    setState(() => _processing = true);

    // Étape 1 : simuler le paiement
    final paymentSuccess = await _mockPayment();
    setState(() => _processing = false);

    if (!paymentSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paiement échoué')),
      );
      return;
    }

    // Étape 2 : créer la commande localement
    await _createLocalOrder(cart);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Commande créée avec succès !')),
    );

    // Étape 3 : navigation vers les commandes
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/orders');
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: cart.items.isEmpty
                  ? const Center(child: Text('Votre panier est vide'))
                  : ListView.builder(
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) {
                        final item = cart.items[index];
                        return ListTile(
                          title: Text(
                            item.product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                              '${item.quantity} x ${item.product.formattedPrice}'),
                          trailing:
                              Text('${item.totalPrice.toStringAsFixed(2)} €'),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Mode de paiement',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedPayment,
              items: <String>['Carte bancaire', 'PayPal', 'Virement']
                  .map((mode) => DropdownMenuItem(
                        value: mode,
                        child: Text(mode),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedPayment = value);
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 16)),
                Text(
                  '${cart.totalAmount.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing || cart.items.isEmpty
                    ? null
                    : () => _handlePayment(cart),
                child: _processing
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Payer'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
