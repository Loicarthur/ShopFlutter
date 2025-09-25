import '../models/product.dart';

class OrderItem {
  final int productId;
  final String title;
  final String image;
  final double unitPrice;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.title,
    required this.image,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromProduct(Product product, int quantity) {
    return OrderItem(
      productId: product.id,
      title: product.title,
      image: product.image,
      unitPrice: product.price,
      quantity: quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'title': title,
        'image': image,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        productId: json['productId'] as int,
        title: json['title'] as String,
        image: json['image'] as String,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );
}

class Order {
  final String id;
  final DateTime createdAt;
  final List<OrderItem> items;
  final double totalAmount;

  Order({
    required this.id,
    required this.createdAt,
    required this.items,
    required this.totalAmount,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'totalAmount': totalAmount,
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        items: (json['items'] as List<dynamic>)
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalAmount: (json['totalAmount'] as num).toDouble(),
      );
}
