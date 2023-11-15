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
  }) : this.quantity = 1;

  // Factory constructor to create a CartItem from a Firestore snapshot
  factory CartItem.fromSnapshot(
      QueryDocumentSnapshot<Map<String, dynamic>> CartDoc,
      DocumentSnapshot<Map<String, dynamic>> ProductsDoc) {
    return CartItem(
      productId: CartDoc['productId'],
      productName: ProductsDoc['productName'],
      productPrice: ProductsDoc['price'].toDouble(),
      productImageUrl: ProductsDoc['imageUrl'],
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
