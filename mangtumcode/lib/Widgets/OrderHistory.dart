import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangtumcode/models/cartItem.dart';

class OrderHistory {
  final double totalAmount;
  final List<CartItem> cartItems;
  final Timestamp createdAt;

  OrderHistory({
    required this.totalAmount,
    required this.cartItems,
    required this.createdAt,
  });

  factory OrderHistory.fromDocument(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    List<CartItem> cartItems = (doc['cartItems'] as List<dynamic>?)
            ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
            .toList() as List<CartItem>? ??
        [];
    return OrderHistory(
      totalAmount: (doc['totalAmount'] ?? 0.0).toDouble(),
      cartItems: cartItems,
      createdAt: doc['created_at'] ?? Timestamp.now(),
    );
  }
}
