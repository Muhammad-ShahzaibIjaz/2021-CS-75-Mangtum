import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mangtumcode/Widgets/OrderHistory.dart';

class OrderHistoryPage extends StatelessWidget {
  final String userId;

  const OrderHistoryPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: FutureBuilder<List<OrderHistory>>(
        future: fetchOrderHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No order history available.'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.all(8.0),
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child:
                      OrderHistoryWidget(orderHistory: snapshot.data![index]),
                );
              },
            );
          }
        },
      ),
    );
  }

  Future<List<OrderHistory>> fetchOrderHistory(String userId) async {
    try {
      QuerySnapshot<Map<String, dynamic>> orderHistorySnapshot =
          await FirebaseFirestore.instance
              .collection('OrderHistory')
              .where('userId', isEqualTo: userId)
              .get();

      return orderHistorySnapshot.docs
          .map((doc) => OrderHistory.fromDocument(doc))
          .toList();
    } catch (e) {
      print('Error fetching order history: $e');

      if (e is FirebaseException && e.code == 'invalid-argument') {
        // Handle the case where the 'userId' field is missing in the documents.
        print(
            'Make sure the "userId" field exists in your OrderHistory documents.');
      }

      return [];
    }
  }
}

class CartItem {
  final String productId;
  final String productName;
  final double productPrice;
  final int quantity;
  final String productImageUrl;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.quantity,
    required this.productImageUrl,
  });

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      productName: map['productName'],
      productPrice: (map['productPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'],
      productImageUrl: map['productImageUrl'],
    );
  }
}

class OrderHistoryWidget extends StatelessWidget {
  final OrderHistory orderHistory;

  const OrderHistoryWidget({Key? key, required this.orderHistory})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Order ID: ${1232123}}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total: \$${orderHistory.totalAmount.toStringAsFixed(2)}'),
          SizedBox(height: 8),
          Text('Products:'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: orderHistory.cartItems.map((item) {
              return Text(
                '${item.productName} - Quantity: ${item.quantity} - \$${item.productPrice.toStringAsFixed(2)}',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
