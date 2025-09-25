import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class StripeService {
  final String backendBaseUrl;
  StripeService({required this.backendBaseUrl});

  Future<void> payWithPaymentSheet({
    required int amountCents,
    required String currency,
    required String customerEmail,
  }) async {
    // 1) Créer PaymentIntent + ephemeral key + customer sur le backend
    final response = await http.post(
      Uri.parse('$backendBaseUrl/create-payment-intent'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountCents,
        'currency': currency,
        'email': customerEmail,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur backend Stripe: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final clientSecret = data['paymentIntentClientSecret'] as String;
    final customerId = data['customer'] as String?;
    final ephemeralKey = data['ephemeralKey'] as String?;

    // 2) Init PaymentSheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        paymentIntentClientSecret: clientSecret,
        merchantDisplayName: 'ShopFlutter',
        customerId: customerId,
        customerEphemeralKeySecret: ephemeralKey,
        style: ThemeMode.system,
        allowsDelayedPaymentMethods: true,
      ),
    );

    // 3) Present PaymentSheet
    await Stripe.instance.presentPaymentSheet();
  }
}
