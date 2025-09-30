import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../models/order.dart';
import '../repositories/order_repository.dart';

enum PaymentMethod { creditCard, paypal, applePay }

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  PaymentMethod _selectedMethod = PaymentMethod.creditCard;
  bool _processing = false;
  final OrderRepository _orderRepo = OrderRepository();

  // Simuler un paiement
  Future<bool> _mockPayment() async {
    await Future.delayed(const Duration(seconds: 2));
    return true;
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

  // Gère la logique métier du paiement et de la création de commande
  Future<bool> _processOrder(CartViewModel cart) async {
    if (cart.items.isEmpty) return false;

    final paymentSuccess = await _mockPayment();
    if (!paymentSuccess) return false;

    await _createLocalOrder(cart);
    return true;
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.creditCard:
        return 'Carte de crédit';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Méthode de paiement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choisissez votre méthode de paiement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Sélection de méthode de paiement moderne
            Column(
              children: PaymentMethod.values.map((method) {
                return ListTile(
                  title: Text(_getPaymentMethodName(method)),
                  leading: GestureDetector(
                    onTap: () => setState(() => _selectedMethod = method),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey),
                        color: _selectedMethod == method ? Colors.blue : Colors.transparent,
                      ),
                      child: _selectedMethod == method
                          ? const Icon(Icons.check, size: 16, color: Colors.white)
                          : null,
                    ),
                  ),
                  onTap: () => setState(() => _selectedMethod = method),
                );
              }).toList(),
            ),

            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total à payer', style: TextStyle(fontSize: 18)),
                Text(
                  '${cart.totalAmount.toStringAsFixed(2)} €',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _processing || cart.items.isEmpty
                    ? null
                    : () async {
                        setState(() => _processing = true);

                        final success = await _processOrder(cart);
                        if (!mounted) return;

                        setState(() => _processing = false);

                        if (!context.mounted) return;
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Commande créée avec succès !')),
                          );
                          Navigator.pushReplacementNamed(context, '/orders');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Le paiement ou la commande a échoué.')),
                          );
                        }
                      },
                child: _processing
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                            strokeWidth: 3, color: Colors.white),
                      )
                    : const Text('Payer maintenant',
                        style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
