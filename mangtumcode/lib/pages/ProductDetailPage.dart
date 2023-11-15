import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  final String productId;
  final String userId;

  ProductDetailPage(this.productId, this.userId);
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  bool isWishlist = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Product Detail'),
        backgroundColor: Colors.amber,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('Products')
            .doc(widget.productId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return Center(child: Text('Product not found'));
          }

          final productData = snapshot.data!;
          final productName = productData['productName'];
          final productDescription = productData['description'];
          final productPrice = productData['price'].toString();
          final imageUrl = productData['imageUrl'];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height / 2,
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.fill,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        productName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isWishlist ? Icons.favorite : Icons.favorite_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          // Toggle wishlist status and update in Firebase
                          setState(() {
                            isWishlist = !isWishlist;
                          });
                          updateWishlistStatus();
                        },
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    productDescription,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price: \$${productPrice}',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 18,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Add to cart logic
                          addToCart();
                        },
                        icon: Icon(Icons.add_shopping_cart),
                        label: Text('Add to Cart'),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void updateWishlistStatus() {
    // Update wishlist status in Firebase
    FirebaseFirestore.instance
        .collection('Wishlist')
        .doc('${widget.userId}_${widget.productId}')
        .set({
      'userId': widget.userId,
      'productId': widget.productId,
      'isWishlist': isWishlist,
    });
  }

  void addToCart() async {
    // Check if the document already exists in Cart
    var cartDoc = await FirebaseFirestore.instance
        .collection('Cart')
        .doc('${widget.userId}_${widget.productId}')
        .get();

    if (cartDoc.exists) {
      // Product is already in the cart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product is already in the cart'),
        ),
      );
    } else {
      // Product is not in the cart, proceed with adding it
      FirebaseFirestore.instance
          .collection('Cart')
          .doc('${widget.userId}_${widget.productId}')
          .set({
        'userId': widget.userId,
        'productId': widget.productId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product added to cart'),
        ),
      );
    }
  }
}
