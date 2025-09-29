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
            RadioListTile<PaymentMethod>(
              title: const Text('Carte de crédit'),
              value: PaymentMethod.creditCard,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('PayPal'),
              value: PaymentMethod.paypal,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
            ),
            RadioListTile<PaymentMethod>(
              title: const Text('Apple Pay'),
              value: PaymentMethod.applePay,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                if (value != null) {
                  setState(() {
                    _selectedMethod = value;
                  });
                }
              },
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
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Paiement avec ${_getPaymentMethodName(_selectedMethod)}...'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                        _handlePayment(cart);
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
