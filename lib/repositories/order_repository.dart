import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';

class OrderRepository {
  static const String _ordersKey = 'orders_v1';

  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_ordersKey);
    if (raw == null || raw.isEmpty) return [];
    final List<dynamic> decoded = json.decode(raw);
    return decoded
        .map((e) => Order.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(orders.map((e) => e.toJson()).toList());
    await prefs.setString(_ordersKey, encoded);
  }

  Future<void> addOrder(Order order) async {
    final current = await getOrders();
    current.insert(0, order);
    await saveOrders(current);
  }
}
