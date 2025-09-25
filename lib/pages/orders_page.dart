import 'package:flutter/material.dart';
import '../repositories/order_repository.dart';
import '../models/order.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  final OrderRepository _repo = OrderRepository();
  late Future<List<Order>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repo.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: FutureBuilder<List<Order>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text('Aucune commande'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              final orderId = order.id != null && order.id!.length >= 8
                  ? order.id!.substring(0, 8)
                  : order.id ?? '???';

              final orderDate = order.createdAt != null
                  ? order.createdAt!.toLocal().toString()
                  : 'Date inconnue';

              return ExpansionTile(
                title: Text(
                    'Commande $orderId • ${order.totalAmount?.toStringAsFixed(2) ?? '0.00'} €'),
                subtitle: Text(orderDate),
                children: (order.items ?? []).map((it) {
                  final imageWidget = (it.image != null && it.image!.isNotEmpty)
                      ? Image.network(it.image!,
                          width: 40, height: 40, fit: BoxFit.cover)
                      : const Icon(Icons.image, size: 40);

                  final title = it.title ?? 'Produit inconnu';
                  final quantity = it.quantity ?? 0;
                  final unitPrice = it.unitPrice ?? 0.0;
                  final lineTotal = it.lineTotal ?? 0.0;

                  return ListTile(
                    leading: imageWidget,
                    title: Text(title,
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle:
                        Text('$quantity x ${unitPrice.toStringAsFixed(2)} €'),
                    trailing: Text('${lineTotal.toStringAsFixed(2)} €'),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
