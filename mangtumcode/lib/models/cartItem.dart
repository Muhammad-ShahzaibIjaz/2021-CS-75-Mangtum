import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String productId;

  final String productName;

  final double productPrice;

  int quantity;

  final String productImageUrl;

  CartItem({
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    this.quantity = 1,
  });

  // Factory constructor to create a CartItem from a Firestore snapshot

  factory CartItem.fromSnapshot(
    QueryDocumentSnapshot<Map<String, dynamic>> cartDoc,
    DocumentSnapshot<Map<String, dynamic>> productDoc,
  ) {
    return CartItem(
      productId: cartDoc['productId'],
      productName: productDoc['productName'],
      productPrice: productDoc['price'].toDouble(),
      productImageUrl: productDoc['imageUrl'],
      quantity: productDoc['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'quantity': quantity,
      'productImageUrl': productImageUrl,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      productId: map['productId'],
      productName: map['productName'],
      productPrice: (map['productPrice'] ?? 0.0).toDouble(),
      quantity: map['quantity'] ?? 1,
      productImageUrl: map['productImageUrl'],
    );
  }
}

class CartService {
  static Future<List<CartItem>> fetchCartItems(String userId) async {
    List<CartItem> items = [];

    // Retrieve cart documents for the user

    QuerySnapshot<Map<String, dynamic>> cartSnapshot = await FirebaseFirestore
        .instance
        .collection('Cart')
        .where('userId', isEqualTo: userId)
        .get();

    for (QueryDocumentSnapshot<Map<String, dynamic>> cartDoc
        in cartSnapshot.docs) {
      // Fetch product details from the Products collection

      DocumentSnapshot<Map<String, dynamic>> productDoc =
          await FirebaseFirestore.instance
              .collection('Products')
              .doc(cartDoc['productId'])
              .get();

      // Check if the product exists in the Products collection

      if (productDoc.exists) {
        // Create a CartItem object

        CartItem item = CartItem.fromSnapshot(cartDoc, productDoc);

        // Add the item to the list

        items.add(item);
      }
    }

    return items;
  }
}
