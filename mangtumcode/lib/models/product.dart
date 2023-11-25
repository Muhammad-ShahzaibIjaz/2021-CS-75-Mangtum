import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String productName;
  final double price;
  final String imageUrl;
  final String description;

  Product({
    required this.productName,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

class ProductService {
  final CollectionReference productsCollection =
      FirebaseFirestore.instance.collection('Products');

  Future<List<Product>> getProducts() async {
    try {
      QuerySnapshot querySnapshot = await productsCollection.get();

      List<Product> products = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Product(
          productName: data['productName'],
          price: data['price'].toDouble(),
          imageUrl: data['imageUrl'],
          description: data['description'],
        );
      }).toList();

      return products;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}
