import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductRepository {
  final CollectionReference _productCollection =
      FirebaseFirestore.instance.collection('products');

  Future<void> createProduct(
    String productName,
    double productPrice,
    String paymentMethodId,
    String imageUrl, // Add an image URL parameter
  ) async {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? uid = user?.uid;

    // Create a new product document
    final DocumentReference productDocRef = _productCollection.doc();
    await productDocRef.set({
      'productName': productName,
      'productPrice': productPrice,
      'sellerId': uid,
      'paymentMethodId': paymentMethodId,
      'imageUrl': imageUrl, // Store the image URL
      // Add other product details as needed
    });

    // You can perform any additional operations here, such as updating the user's earnings or order history.
  }
}
