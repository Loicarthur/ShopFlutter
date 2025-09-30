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
  List<Order>? _orders;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final orders = await _repo.getOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Erreur: $_error'));
    }

    final orders = _orders!;

    if (orders.isEmpty) {
      return const Center(child: Text('Aucune commande'));
    }

    return _buildOrdersList(context, orders);
  }

  Widget _buildOrdersList(BuildContext context, List<Order> orders) {
    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];

        final orderId =
            order.id.length >= 8 ? order.id.substring(0, 8) : order.id;

        final orderDate = order.createdAt.toLocal().toString();

        return ExpansionTile(
          title: Text(
              'Commande $orderId • ${order.totalAmount.toStringAsFixed(2)} €'),
          subtitle: Text(orderDate),
          children: order.items.map((it) {
            final imageWidget = Image.network(it.image,
                width: 40, height: 40, fit: BoxFit.cover);

            return ListTile(
              leading: imageWidget,
              title:
                  Text(it.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle:
                  Text('${it.quantity} x ${it.unitPrice.toStringAsFixed(2)} €'),
              trailing: Text('${it.lineTotal.toStringAsFixed(2)} €'),
            );
          }).toList(),
        );
      },
    );
  }
}
